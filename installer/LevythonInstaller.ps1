param(
    [switch]$SkipBuild,
    [switch]$CreateSFX,
    [string]$Architecture = "both"  # Build both x64 and x86 by default
)

$ErrorActionPreference = "Stop"

$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
$script:BuildDir = Join-Path $script:ProjectRoot "build"
$script:ReleaseDir = Join-Path $script:ProjectRoot "releases"
$script:InstallerDir = $PSScriptRoot
$script:Version = "1.0.2"

# 32-bit MinGW location
$script:MinGW32Path = "C:\Users\Tirth\Desktop\mingw-w32-bin_i686-mingw_20111219\bin"

# Determine architectures to build
if ($Architecture -eq "both") {
    $script:Architectures = @("x64", "x86")
} elseif ($Architecture -eq "auto") {
    $script:Architectures = @(
        if ([Environment]::Is64BitOperatingSystem) {
            if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
        } else { "x86" }
    )
} else {
    $script:Architectures = @($Architecture)
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Levython Installer Build" -ForegroundColor Cyan
Write-Host ("Version: " + $script:Version)
Write-Host ("Targets: " + ($script:Architectures -join ", "))
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

New-Item -ItemType Directory -Path $script:BuildDir -Force | Out-Null
New-Item -ItemType Directory -Path $script:ReleaseDir -Force | Out-Null

function Find-Compiler {
    Write-Host "Searching for C++ compiler..." -ForegroundColor Yellow
    
    # Prefer MinGW g++ for cross-architecture builds (supports -m32 and -m64)
    $gpp = Get-Command g++ -ErrorAction SilentlyContinue
    if ($gpp) { 
        Write-Host "  Found: g++ (MinGW)" -ForegroundColor Green
        return @{ Type = "g++"; Path = $gpp.Source } 
    }
    
    # Fallback to MSVC (harder to cross-compile x86 on x64)
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vsWhere) {
        $vsPath = & $vsWhere -latest -property installationPath 2>$null
        if ($vsPath) { 
            Write-Host "  Found: MSVC" -ForegroundColor Green
            return @{ Type = "msvc"; VsPath = $vsPath } 
        }
    }
    
    # Fallback to Clang
    $clang = Get-Command clang++ -ErrorAction SilentlyContinue
    if ($clang) { 
        Write-Host "  Found: clang++" -ForegroundColor Green
        return @{ Type = "clang++"; Path = $clang.Source } 
    }
    
    return $null
}

function Find-OpenSSL {
    $candidates = @()
    if ($env:OPENSSL_DIR) { $candidates += $env:OPENSSL_DIR }
    
    # Add Scoop paths
    if ($env:USERPROFILE) {
        $candidates += "$env:USERPROFILE\scoop\apps\openssl\current"
        $candidates += "$env:USERPROFILE\scoop\apps\mingw\current\opt\include"
    }
    $candidates += "C:\ProgramData\scoop\apps\openssl\current"
    
    # Add architecture-specific OpenSSL paths
    if ($script:Arch -eq "x86") {
        $candidates += "C:\OpenSSL-Win32"
        $candidates += "${env:ProgramFiles(x86)}\OpenSSL-Win32"
        $candidates += "C:\Program Files (x86)\OpenSSL-Win32"
        $candidates += "C:\vcpkg\installed\x86-windows"
    } else {
        $candidates += "C:\OpenSSL-Win64"
        $candidates += "${env:ProgramFiles}\OpenSSL-Win64"
        $candidates += "C:\Program Files\OpenSSL-Win64"
        $candidates += "C:\vcpkg\installed\x64-windows"
    }
    
    # Check MinGW's built-in OpenSSL
    $mingwPath = (Get-Command g++ -ErrorAction SilentlyContinue)
    if ($mingwPath) {
        $mingwRoot = Split-Path (Split-Path $mingwPath.Source)
        $candidates += "$mingwRoot"
        $candidates += "$mingwRoot\opt"
    }

    foreach ($base in $candidates) {
        if (-not (Test-Path $base)) { continue }
        $inc = Join-Path $base "include"
        
        # Try standard lib location first
        $lib = Join-Path $base "lib"
        if ((Test-Path $inc) -and (Test-Path $lib)) {
            # Check for MSVC-style lib structure based on architecture
            if ($script:Arch -eq "x86") {
                $vcLib = Join-Path $lib "VC\x86\MT"
                if (Test-Path $vcLib) {
                    Write-Host "  Found OpenSSL (x86): $base" -ForegroundColor Cyan
                    return @{ Include = $inc; Lib = $vcLib }
                }
                $vcLib = Join-Path $lib "VC\Win32\MT"
                if (Test-Path $vcLib) {
                    Write-Host "  Found OpenSSL (x86): $base" -ForegroundColor Cyan
                    return @{ Include = $inc; Lib = $vcLib }
                }
            } else {
                $vcLib = Join-Path $lib "VC\x64\MT"
                if (Test-Path $vcLib) {
                    Write-Host "  Found OpenSSL (x64): $base" -ForegroundColor Cyan
                    return @{ Include = $inc; Lib = $vcLib }
                }
            }
            
            # Check if lib contains actual .lib or .a files
            $hasLibs = (Get-ChildItem $lib -Filter "*.lib" -ErrorAction SilentlyContinue) -or (Get-ChildItem $lib -Filter "*.a" -ErrorAction SilentlyContinue)
            if ($hasLibs) {
                Write-Host "  Found OpenSSL: $base" -ForegroundColor Cyan
                return @{ Include = $inc; Lib = $lib }
            }
        }
    }
    return $null
}

function Build-Executable {
    param([string]$OutputPath)

    $srcFile = Join-Path $script:ProjectRoot "src\levython.cpp"
    $httpFile = Join-Path $script:ProjectRoot "src\http_client.cpp"
    $srcFiles = @($srcFile)
    if (Test-Path $httpFile) { $srcFiles += $httpFile }
    if (-not (Test-Path $srcFile)) { throw "Source file not found: $srcFile" }

    $compiler = Find-Compiler
    if (-not $compiler) { throw "No C++ compiler found. Install MinGW-w64 or Visual Studio." }

    Write-Host ("Building Levython (" + $script:Arch + ")...") -ForegroundColor Yellow

    $openssl = Find-OpenSSL
    if (-not $openssl) { throw "OpenSSL not found. Set OPENSSL_DIR or install OpenSSL (libssl/libcrypto)." }

    switch ($compiler.Type) {
        "g++" {
            # Determine which compiler to use based on architecture
            if ($script:Arch -eq "x86") {
                # Use dedicated 32-bit MinGW
                $gppPath = Join-Path $script:MinGW32Path "i686-w64-mingw32-g++.exe"
                if (-not (Test-Path $gppPath)) {
                    throw "32-bit MinGW not found at: $script:MinGW32Path"
                }
                Write-Host "  Using 32-bit MinGW: $gppPath" -ForegroundColor Cyan
                $archFlag = ""  # Native 32-bit compiler, no flag needed
            } else {
                # Use system g++ (64-bit)
                $gppPath = "g++"
                $archFlag = "-m64"
            }
            
            Write-Host ("  [INFO] Compiling with -O3 optimization (this takes time but makes it fast)") -ForegroundColor Cyan
            Write-Host ("  [INFO] Total files: " + $srcFiles.Count) -ForegroundColor Cyan
            
            # Compile each source file separately to show progress
            $objFiles = @()
            $fileNum = 0
            $totalFiles = $srcFiles.Count
            
            foreach ($srcFile in $srcFiles) {
                $fileNum++
                $fileName = [System.IO.Path]::GetFileNameWithoutExtension($srcFile)
                $objFile = Join-Path $script:BuildDir "$fileName.o"
                $objFiles += $objFile
                
                Write-Host ("") -NoNewline
                Write-Host ("  [$fileNum/$totalFiles] Compiling $fileName.cpp...") -ForegroundColor Yellow -NoNewline
                $startTime = Get-Date
                
                # Compile WITHOUT LTO to speed up individual compilation, add LTO only at link time
                $compileArgs = @(
                    "-std=c++17","-O3","-DNDEBUG","-fexceptions",
                    "-I", $openssl.Include,
                    "-c", $srcFile, "-o", $objFile
                )
                if ($archFlag) { $compileArgs = @($archFlag) + $compileArgs }
                
                # Show command being run
                Write-Host (" ($gppPath " + ($compileArgs -join " ") + ")") -ForegroundColor DarkGray
                
                $compileOutput = & $gppPath $compileArgs 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Host ""
                    Write-Host $compileOutput
                    throw "Compilation of $fileName.cpp failed"
                }
                
                $elapsed = ((Get-Date) - $startTime).TotalSeconds
                Write-Host ("         [OK] Done in " + [math]::Round($elapsed, 1) + "s") -ForegroundColor Green
            }
            
            # Link all object files with LTO
            Write-Host ("") -NoNewline
            Write-Host ("  [LINK] Linking with LTO optimization...") -ForegroundColor Yellow -NoNewline
            $linkStartTime = Get-Date
            
            $linkArgs = @(
                "-static","-static-libgcc","-static-libstdc++","-flto","-fexceptions",
                "-L", $openssl.Lib,
                "-o", $OutputPath
            ) + $objFiles + @("-llibssl","-llibcrypto","-lws2_32","-lcrypt32")
            if ($archFlag) { $linkArgs = @($archFlag) + $linkArgs }
            
            Write-Host (" (this may take 5-10 min on slow PCs)") -ForegroundColor DarkGray
            
            $linkOutput = & $gppPath $linkArgs 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host ""
                Write-Host $linkOutput
                throw "Linking failed"
            }
            
            $linkElapsed = ((Get-Date) - $linkStartTime).TotalSeconds
            Write-Host ("         [OK] Linked in " + [math]::Round($linkElapsed, 1) + "s") -ForegroundColor Green
        }
        "msvc" {
            $vcvarsall = Join-Path $compiler.VsPath "VC\Auxiliary\Build\vcvarsall.bat"
            $msvcArch = switch ($script:Arch) { "x64" { "x64" } "x86" { "x86" } "arm64" { "arm64" } }
            $srcList = ($srcFiles | ForEach-Object { "`"$_`"" }) -join " "
            $buildCmd = 'call "' + $vcvarsall + '" ' + $msvcArch + "`r`n" +
                'cl.exe /std:c++17 /O2 /EHsc /DNDEBUG /I"' + $openssl.Include + '" /Fe:"' + $OutputPath + '" ' + $srcList + ' /link /LIBPATH:"' + $openssl.Lib + '" libssl.lib libcrypto.lib ws2_32.lib crypt32.lib'
            $buildScript = Join-Path $script:BuildDir "build_msvc.bat"
            Set-Content -Path $buildScript -Value $buildCmd
            cmd.exe /c $buildScript 2>&1
        }
        "clang++" {
            $args = @(
                "-std=c++17","-O3","-DNDEBUG","-static","-flto","-fexceptions",
                "-I", $openssl.Include, "-L", $openssl.Lib,
                "-lssl","-lcrypto","-lws2_32","-lcrypt32",
                "-o", $OutputPath
            ) + $srcFiles
            & clang++ $args 2>&1
        }
    }

    if ($LASTEXITCODE -ne 0) { throw "Build failed with exit code $LASTEXITCODE" }
    if (-not (Test-Path $OutputPath)) { throw "Build completed but executable not found: $OutputPath" }
    $sizeMB = [math]::Round(((Get-Item $OutputPath).Length / 1MB), 2)
    Write-Host ("Build successful: " + $OutputPath + " (" + $sizeMB + " MB)") -ForegroundColor Green
}

function Create-InstallerPackage {
    Write-Host "Creating installer package..." -ForegroundColor Yellow

    $packageDir = Join-Path $script:BuildDir "package"
    Remove-Item -Path $packageDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $packageDir -Force | Out-Null

    $exePath = Join-Path $script:ReleaseDir ("levython-windows-" + $script:Arch + ".exe")
    if (-not (Test-Path $exePath)) { $exePath = Join-Path $script:ProjectRoot "levython.exe" }
    Copy-Item -Path $exePath -Destination (Join-Path $packageDir "levython.exe")

    Copy-Item -Path (Join-Path $script:InstallerDir "LevythonInstaller.ps1") -Destination $packageDir
    Copy-Item -Path (Join-Path $script:InstallerDir "Install-Levython.bat") -Destination $packageDir

    $docs = @("README.md", "LICENSE", "CHANGELOG.md")
    foreach ($doc in $docs) {
        $docPath = Join-Path $script:ProjectRoot $doc
        if (Test-Path $docPath) { Copy-Item -Path $docPath -Destination $packageDir }
    }

    $examplesDir = Join-Path $script:ProjectRoot "examples"
    if (Test-Path $examplesDir) { Copy-Item -Path $examplesDir -Destination (Join-Path $packageDir "examples") -Recurse }

    $vscodeDir = Join-Path $script:ProjectRoot "vscode-levython"
    if (Test-Path $vscodeDir) { Copy-Item -Path $vscodeDir -Destination (Join-Path $packageDir "vscode-levython") -Recurse }

    $zipPath = Join-Path $script:ReleaseDir ("levython-" + $script:Version + "-windows-" + $script:Arch + "-installer.zip")
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
    Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

    $sizeMB = [math]::Round(((Get-Item $zipPath).Length / 1MB), 2)
    Write-Host ("Package created: " + $zipPath + " (" + $sizeMB + " MB)") -ForegroundColor Green
    return $zipPath
}

function Create-SelfExtractor {
    param([string]$ZipPath)

    Write-Host "Creating self-extracting installer..." -ForegroundColor Yellow

    $sevenZip = Get-Command 7z -ErrorAction SilentlyContinue
    if (-not $sevenZip) {
        $sevenZipPaths = @("$env:ProgramFiles\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe")
        foreach ($path in $sevenZipPaths) {
            if (Test-Path $path) { $sevenZip = @{ Source = $path }; break }
        }
    }
    if (-not $sevenZip) { Write-Host "7-Zip not found, skipping SFX creation" -ForegroundColor Yellow; return $null }

    $sfxPath = Join-Path $script:ReleaseDir ("levython-" + $script:Version + "-windows-" + $script:Arch + "-setup.exe")
    $packageDir = Join-Path $script:BuildDir "package"
    $archivePath = Join-Path $script:BuildDir "installer.7z"
    & $sevenZip.Source a -t7z -mx=9 $archivePath "$packageDir\*" | Out-Null

    $sfxModule = Join-Path (Split-Path $sevenZip.Source) "7z.sfx"
    if (-not (Test-Path $sfxModule)) { Write-Host "SFX module not found" -ForegroundColor Yellow; return $null }

    $configPath = Join-Path $script:BuildDir "config.txt"
    $cfg = ';!@Install@!UTF-8!' + "`r`n" +
        'Title="Levython Installer"' + "`r`n" +
        'BeginPrompt="Install Levython ' + $script:Version + '?"' + "`r`n" +
        'RunProgram="Install-Levython.bat"' + "`r`n" +
        ';!@InstallEnd@!'
    Set-Content -Path $configPath -Value $cfg

    $sfxBytes = [System.IO.File]::ReadAllBytes($sfxModule)
    $configBytes = [System.IO.File]::ReadAllBytes($configPath)
    $archiveBytes = [System.IO.File]::ReadAllBytes($archivePath)

    $output = New-Object byte[] ($sfxBytes.Length + $configBytes.Length + $archiveBytes.Length)
    [System.Buffer]::BlockCopy($sfxBytes, 0, $output, 0, $sfxBytes.Length)
    [System.Buffer]::BlockCopy($configBytes, 0, $output, $sfxBytes.Length, $configBytes.Length)
    [System.Buffer]::BlockCopy($archiveBytes, 0, $output, $sfxBytes.Length + $configBytes.Length, $archiveBytes.Length)
    [System.IO.File]::WriteAllBytes($sfxPath, $output)

    $sizeMB = [math]::Round(((Get-Item $sfxPath).Length / 1MB), 2)
    Write-Host ("SFX created: " + $sfxPath + " (" + $sizeMB + " MB)") -ForegroundColor Green
    return $sfxPath
}

try {
    foreach ($arch in $script:Architectures) {
        $script:Arch = $arch
        
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Magenta
        Write-Host ("Building for: " + $arch) -ForegroundColor Magenta
        Write-Host "============================================================" -ForegroundColor Magenta
        Write-Host ""
        
        if (-not $SkipBuild) {
            $exePath = Join-Path $script:ReleaseDir ("levython-windows-" + $script:Arch + ".exe")
            Build-Executable -OutputPath $exePath
        }
        
        $zipPath = Create-InstallerPackage
        
        if ($CreateSFX) { 
            Create-SelfExtractor -ZipPath $zipPath 
        }
        
        Write-Host ""
        Write-Host ("[OK] Build completed for " + $arch) -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "All builds completed successfully!" -ForegroundColor Green
    Write-Host ("Output files in: " + $script:ReleaseDir) -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Green
} catch {
    Write-Host ("Build failed: " + $_) -ForegroundColor Red
    exit 1
}
