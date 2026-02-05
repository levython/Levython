<#
.SYNOPSIS
    Build complete Levython Windows installer package
.DESCRIPTION
    This script:
    1. Detects system architecture
    2. Compiles Levython from source
    3. Creates installer package
    4. Optionally creates self-extracting installer
.NOTES
    Run from Developer Command Prompt for full build capabilities
#>

param(
    [switch]$SkipBuild,
    [switch]$CreateSFX,
    [string]$Architecture = "auto"
)

$ErrorActionPreference = "Stop"

# Configuration
$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
$script:BuildDir = Join-Path $script:ProjectRoot "build"
$script:ReleaseDir = Join-Path $script:ProjectRoot "releases"
$script:InstallerDir = $PSScriptRoot
$script:Version = "1.0.1"

# Detect architecture
if ($Architecture -eq "auto") {
    $script:Arch = if ([Environment]::Is64BitOperatingSystem) {
        if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    } else { "x86" }
} else {
    $script:Arch = $Architecture
}

Write-Host "`n" -NoNewline
Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           LEVYTHON INSTALLER BUILD SYSTEM                         ║" -ForegroundColor Cyan
Write-Host "╠═══════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  Version: $script:Version                                                  ║" -ForegroundColor Cyan
Write-Host "║  Target:  $($script:Arch.PadRight(57))║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Create directories
New-Item -ItemType Directory -Path $script:BuildDir -Force | Out-Null
New-Item -ItemType Directory -Path $script:ReleaseDir -Force | Out-Null

function Find-Compiler {
    Write-Host "[*] Searching for C++ compiler..." -ForegroundColor Yellow
    
    # Check for g++ (MinGW)
    $gpp = Get-Command g++ -ErrorAction SilentlyContinue
    if ($gpp) {
        Write-Host "    Found: g++ (MinGW)" -ForegroundColor Green
        return @{ Type = "g++"; Path = $gpp.Source }
    }
    
    # Check for MSVC via vswhere
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vsWhere) {
        $vsPath = & $vsWhere -latest -property installationPath 2>$null
        if ($vsPath) {
            Write-Host "    Found: MSVC (Visual Studio)" -ForegroundColor Green
            return @{ Type = "msvc"; VsPath = $vsPath }
        }
    }
    
    # Check for clang++
    $clang = Get-Command clang++ -ErrorAction SilentlyContinue
    if ($clang) {
        Write-Host "    Found: clang++" -ForegroundColor Green
        return @{ Type = "clang++"; Path = $clang.Source }
    }
    
    return $null
}

function Build-Executable {
    param([string]$OutputPath)
    
    $srcFile = Join-Path $script:ProjectRoot "src\levython.cpp"
    
    if (-not (Test-Path $srcFile)) {
        throw "Source file not found: $srcFile"
    }
    
    $compiler = Find-Compiler
    if (-not $compiler) {
        throw "No C++ compiler found. Install MinGW-w64 or Visual Studio."
    }
    
    Write-Host "[*] Building Levython ($($script:Arch))..." -ForegroundColor Yellow
    
    switch ($compiler.Type) {
        "g++" {
            $archFlag = switch ($script:Arch) {
                "x64" { "-m64" }
                "x86" { "-m32" }
                "arm64" { "" }
            }
            
            $args = @(
                "-std=c++17",
                "-O3",
                "-DNDEBUG",
                "-static",
                "-static-libgcc",
                "-static-libstdc++",
                "-flto",
                "-fexceptions",
                "-o", $OutputPath,
                $srcFile
            )
            if ($archFlag) { $args = @($archFlag) + $args }
            
            Write-Host "    g++ $($args -join ' ')" -ForegroundColor DarkGray
            & g++ $args 2>&1
        }
        
        "msvc" {
            $vcvarsall = Join-Path $compiler.VsPath "VC\Auxiliary\Build\vcvarsall.bat"
            $msvcArch = switch ($script:Arch) {
                "x64" { "x64" }
                "x86" { "x86" }
                "arm64" { "arm64" }
            }
            
            $buildCmd = @"
call "$vcvarsall" $msvcArch
cl.exe /std:c++17 /O2 /EHsc /DNDEBUG /Fe:"$OutputPath" "$srcFile"
"@
            $buildScript = Join-Path $script:BuildDir "build_msvc.bat"
            Set-Content -Path $buildScript -Value $buildCmd
            
            Write-Host "    cl.exe /std:c++17 /O2 /EHsc..." -ForegroundColor DarkGray
            cmd.exe /c $buildScript 2>&1
        }
        
        "clang++" {
            $args = @(
                "-std=c++17",
                "-O3",
                "-DNDEBUG",
                "-static",
                "-flto",
                "-fexceptions",
                "-o", $OutputPath,
                $srcFile
            )
            
            Write-Host "    clang++ $($args -join ' ')" -ForegroundColor DarkGray
            & clang++ $args 2>&1
        }
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed with exit code $LASTEXITCODE"
    }
    
    if (-not (Test-Path $OutputPath)) {
        throw "Build completed but executable not found: $OutputPath"
    }
    
    $size = (Get-Item $OutputPath).Length / 1MB
    Write-Host "[+] Build successful: $OutputPath ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
}

function Create-InstallerPackage {
    Write-Host "[*] Creating installer package..." -ForegroundColor Yellow
    
    $packageDir = Join-Path $script:BuildDir "package"
    Remove-Item -Path $packageDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
    
    # Copy executable
    $exePath = Join-Path $script:ReleaseDir "levython-windows-$($script:Arch).exe"
    if (-not (Test-Path $exePath)) {
        $exePath = Join-Path $script:ProjectRoot "levython.exe"
    }
    Copy-Item -Path $exePath -Destination (Join-Path $packageDir "levython.exe")
    
    # Copy installer scripts
    Copy-Item -Path (Join-Path $script:InstallerDir "LevythonInstaller.ps1") -Destination $packageDir
    Copy-Item -Path (Join-Path $script:InstallerDir "Install-Levython.bat") -Destination $packageDir
    
    # Copy documentation
    $docs = @("README.md", "LICENSE", "CHANGELOG.md")
    foreach ($doc in $docs) {
        $docPath = Join-Path $script:ProjectRoot $doc
        if (Test-Path $docPath) {
            Copy-Item -Path $docPath -Destination $packageDir
        }
    }
    
    # Copy examples
    $examplesDir = Join-Path $script:ProjectRoot "examples"
    if (Test-Path $examplesDir) {
        Copy-Item -Path $examplesDir -Destination (Join-Path $packageDir "examples") -Recurse
    }
    
    # Copy VS Code extension
    $vscodeDir = Join-Path $script:ProjectRoot "vscode-levython"
    if (Test-Path $vscodeDir) {
        Copy-Item -Path $vscodeDir -Destination (Join-Path $packageDir "vscode-levython") -Recurse
    }
    
    # Create ZIP package
    $zipPath = Join-Path $script:ReleaseDir "levython-$script:Version-windows-$($script:Arch)-installer.zip"
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
    Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath -CompressionLevel Optimal
    
    $size = (Get-Item $zipPath).Length / 1MB
    Write-Host "[+] Package created: $zipPath ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
    
    return $zipPath
}

function Create-SelfExtractor {
    param([string]$ZipPath)
    
    Write-Host "[*] Creating self-extracting installer..." -ForegroundColor Yellow
    
    # Use 7-Zip if available for SFX creation
    $sevenZip = Get-Command 7z -ErrorAction SilentlyContinue
    if (-not $sevenZip) {
        $sevenZipPaths = @(
            "$env:ProgramFiles\7-Zip\7z.exe",
            "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
        )
        foreach ($path in $sevenZipPaths) {
            if (Test-Path $path) {
                $sevenZip = @{ Source = $path }
                break
            }
        }
    }
    
    if (-not $sevenZip) {
        Write-Host "    7-Zip not found, skipping SFX creation" -ForegroundColor Yellow
        return $null
    }
    
    $sfxPath = Join-Path $script:ReleaseDir "levython-$script:Version-windows-$($script:Arch)-setup.exe"
    $packageDir = Join-Path $script:BuildDir "package"
    
    # Create 7z archive
    $archivePath = Join-Path $script:BuildDir "installer.7z"
    & $sevenZip.Source a -t7z -mx=9 $archivePath "$packageDir\*" | Out-Null
    
    # Get SFX module
    $sfxModule = Join-Path (Split-Path $sevenZip.Source) "7z.sfx"
    if (-not (Test-Path $sfxModule)) {
        Write-Host "    SFX module not found" -ForegroundColor Yellow
        return $null
    }
    
    # Create config file
    $configPath = Join-Path $script:BuildDir "config.txt"
    @"
;!@Install@!UTF-8!
Title="Levython Installer"
BeginPrompt="Install Levython $script:Version?"
RunProgram="Install-Levython.bat"
;!@InstallEnd@!
"@ | Set-Content -Path $configPath
    
    # Combine SFX + config + archive
    $sfxBytes = [System.IO.File]::ReadAllBytes($sfxModule)
    $configBytes = [System.IO.File]::ReadAllBytes($configPath)
    $archiveBytes = [System.IO.File]::ReadAllBytes($archivePath)
    
    $output = New-Object byte[] ($sfxBytes.Length + $configBytes.Length + $archiveBytes.Length)
    [System.Buffer]::BlockCopy($sfxBytes, 0, $output, 0, $sfxBytes.Length)
    [System.Buffer]::BlockCopy($configBytes, 0, $output, $sfxBytes.Length, $configBytes.Length)
    [System.Buffer]::BlockCopy($archiveBytes, 0, $output, $sfxBytes.Length + $configBytes.Length, $archiveBytes.Length)
    [System.IO.File]::WriteAllBytes($sfxPath, $output)
    
    $size = (Get-Item $sfxPath).Length / 1MB
    Write-Host "[+] SFX created: $sfxPath ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
    
    return $sfxPath
}

# Main execution
try {
    if (-not $SkipBuild) {
        $exePath = Join-Path $script:ReleaseDir "levython-windows-$($script:Arch).exe"
        Build-Executable -OutputPath $exePath
    }
    
    $zipPath = Create-InstallerPackage
    
    if ($CreateSFX) {
        Create-SelfExtractor -ZipPath $zipPath
    }
    
    Write-Host "`n" -NoNewline
    Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    BUILD COMPLETED SUCCESSFULLY                   ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output files in: $script:ReleaseDir" -ForegroundColor Cyan
    Get-ChildItem -Path $script:ReleaseDir -Filter "levython-$script:Version*" | 
        ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
    Write-Host ""
}
catch {
    Write-Host "`n[!] Build failed: $_" -ForegroundColor Red
    exit 1
}