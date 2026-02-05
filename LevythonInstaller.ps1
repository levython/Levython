<#
.SYNOPSIS
    Levython Professional Windows Installer
.DESCRIPTION
    A complete GUI installer for Levython that:
    - Auto-detects system architecture (x64/x86/ARM64)
    - Builds from source or uses pre-built binary
    - Configures system PATH
    - Installs VS Code extension
    - Creates file associations
.NOTES
    Version: 1.0.1
    Author: Levython Authors
#>

# Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

# ============================================================================
# CONFIGURATION
# ============================================================================
$script:AppName = "Levython"
$script:AppVersion = "1.0.1"
$script:InstallDir = "$env:ProgramFiles\Levython"
$script:SourceDir = $PSScriptRoot
$script:LogFile = "$env:TEMP\levython-install.log"

# Compiler selection (user-defined)
# Allowed values: "mingw", "clang", "msvc"
$script:CompilerChoice = "mingw"

# Architecture detection
$script:Architecture = switch ([System.Environment]::Is64BitOperatingSystem) {
    $true { 
        if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "ARM64" } 
        else { "x64" }
    }
    $false { "x86" }
}

# ============================================================================
# LOGGING
# ============================================================================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $script:LogFile -Value $logMessage -ErrorAction SilentlyContinue
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-VSCodePath {
    $paths = @(
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd",
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

function Find-Compiler {

    Write-Log "Compiler choice: $script:CompilerChoice" "INFO"

    switch ($script:CompilerChoice) {

        "mingw" {
            $gpp = Get-Command g++ -ErrorAction SilentlyContinue
            if ($gpp) {
                return @{ Type = "g++"; Path = $gpp.Source }
            }
            throw "MinGW selected, but g++ was not found in PATH. Please install MSYS2/MinGW and add it to PATH."
        }

        "clang" {
            $clang = Get-Command clang++ -ErrorAction SilentlyContinue
            if ($clang) {
                return @{ Type = "clang++"; Path = $clang.Source }
            }
            throw "Clang selected, but clang++ was not found in PATH. Please install LLVM/Clang and add it to PATH."
        }

        "msvc" {

            $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
            if (-not (Test-Path $vsWhere)) {
                throw "Visual Studio Installer not found"
            }

            $vsPath = & $vsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath

            if (-not $vsPath) {
                throw "MSVC Build Tools not installed"
            }

            $vcvarsall = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat"
            if (-not (Test-Path $vcvarsall)) {
                throw "vcvarsall.bat not found"
            }

            return @{
                Type   = "msvc"
                VsPath = $vsPath
            }
        }
        default {
            throw "Invalid CompilerChoice: $script:CompilerChoice (expected 'mingw', 'clang', or 'msvc')"
        }
    }
}

function Add-ToPath {
    param([string]$PathToAdd)
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if ($currentPath -notlike "*$PathToAdd*") {
        $newPath = "$currentPath;$PathToAdd"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
        Write-Log "Added $PathToAdd to system PATH" "SUCCESS"
        return $true
    }
    Write-Log "Path already contains $PathToAdd" "INFO"
    return $false
}

function Remove-FromPath {
    param([string]$PathToRemove)
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $paths = $currentPath -split ";" | Where-Object { $_ -ne $PathToRemove -and $_ -ne "" }
    $newPath = $paths -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
}

# ============================================================================
# BUILD FUNCTIONS
# ============================================================================
function Build-Levython {
    param([string]$OutputPath)
    
    $compiler = Find-Compiler
    if (-not $compiler) {
        throw "No C++ compiler found. Please install MinGW-w64 or Visual Studio."
    }
    
    Write-Log "Building Levython with $($compiler.Type)..." "INFO"
    
    $srcFile = Join-Path $script:SourceDir "src\levython.cpp"
    if (-not (Test-Path $srcFile)) {
        throw "Source file not found: $srcFile"
    }
    
    $buildArgs = switch ($compiler.Type) {
        "g++" {
            @(
                "-std=c++17",
                "-O3",
                "-DNDEBUG",
                "-static",
                "-static-libgcc",
                "-static-libstdc++",
                "-fexceptions",
                "-o", $OutputPath,
                $srcFile
            )
        }
        "clang++" {
            @(
                "-std=c++17",
                "-O3",
                "-DNDEBUG",
                "-static",
                "-fexceptions",
                "-o", $OutputPath,
                $srcFile
            )
        }
        "msvc" {
            # For MSVC, we need to set up the environment
            @(
                "/std:c++17",
                "/O2",
                "/EHsc",
                "/DNDEBUG",
                "/Fe:`"$OutputPath`"",
                $srcFile
            )
        }
    }
    
    try {
        if ($compiler.Type -eq "msvc") {

            # Use Developer Command Prompt
            $vcvarsall = Join-Path $compiler.VsPath "VC\Auxiliary\Build\vcvarsall.bat"

            # IMPORTANT: vcvarsall uses amd64, NOT x64
            $arch = "amd64"

            $cmd = "`"$vcvarsall`" $arch && cl.exe $($buildArgs -join ' ')"
            Write-Log "Running MSVC build: $cmd" "INFO"

            $result = cmd.exe /c $cmd 2>&1
        }
        else {
            $result = & $compiler.Path $buildArgs 2>&1
        }

        if ($LASTEXITCODE -ne 0) {
            throw "Build failed: $result"
        }

        if (-not (Test-Path $OutputPath)) {
            throw "Build completed but executable not found"
        }

        Write-Log "Build successful: $OutputPath" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Build failed: $_" "ERROR"
        throw
    }
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================
function Install-Levython {
    param(
        [string]$InstallPath,
        [bool]$AddToPath = $true,
        [bool]$InstallVSCode = $true,
        [bool]$CreateShortcut = $true,
        [bool]$AssociateFiles = $true
    )
    
    Write-Log "Starting Levython installation..." "INFO"
    Write-Log "Install path: $InstallPath" "INFO"
    Write-Log "Architecture: $script:Architecture" "INFO"
    
    # Create installation directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
        Write-Log "Created directory: $InstallPath" "INFO"
    }
    
    # Check for pre-built binary
    $prebuiltPath = Join-Path $script:SourceDir "levython.exe"
    $targetExe = Join-Path $InstallPath "levython.exe"
    
    if (Test-Path $prebuiltPath) {
        Write-Log "Using pre-built binary..." "INFO"
        Copy-Item -Path $prebuiltPath -Destination $targetExe -Force
    }
    else {
        Write-Log "Building from source..." "INFO"
        Build-Levython -OutputPath $targetExe
    }
    
    # Copy documentation
    $docs = @("README.md", "LICENSE", "CHANGELOG.md", "IMPLEMENTATION_SUMMARY.md", "JIT_OPTIMIZATIONS.md")
    foreach ($doc in $docs) {
        $docPath = Join-Path $script:SourceDir $doc
        if (Test-Path $docPath) {
            Copy-Item -Path $docPath -Destination $InstallPath -Force
        }
    }
    
    # Copy examples
    $examplesDir = Join-Path $script:SourceDir "examples"
    if (Test-Path $examplesDir) {
        $targetExamples = Join-Path $InstallPath "examples"
        Copy-Item -Path $examplesDir -Destination $targetExamples -Recurse -Force
        Write-Log "Copied examples" "INFO"
    }
    
    # Add to PATH
    if ($AddToPath) {
        Add-ToPath -PathToAdd $InstallPath
    }
    
    # Install VS Code extension
    if ($InstallVSCode) {
        $vscodePath = Get-VSCodePath
        if ($vscodePath) {
            $extensionDir = Join-Path $script:SourceDir "vscode-levython"
            if (Test-Path $extensionDir) {
                Write-Log "Installing VS Code extension..." "INFO"
                try {
                    & $vscodePath --install-extension $extensionDir --force 2>&1 | Out-Null
                    Write-Log "VS Code extension installed" "SUCCESS"
                }
                catch {
                    Write-Log "VS Code extension installation failed: $_" "WARN"
                }
            }
        }
        else {
            Write-Log "VS Code not found, skipping extension installation" "WARN"
        }
    }
    
    # Create file associations
    if ($AssociateFiles) {
        try {
            # .levy extension
            New-Item -Path "HKCR:\.levy" -Force | Out-Null
            Set-ItemProperty -Path "HKCR:\.levy" -Name "(Default)" -Value "LevythonScript"
            
            New-Item -Path "HKCR:\LevythonScript" -Force | Out-Null
            Set-ItemProperty -Path "HKCR:\LevythonScript" -Name "(Default)" -Value "Levython Script"
            
            New-Item -Path "HKCR:\LevythonScript\shell\open\command" -Force | Out-Null
            Set-ItemProperty -Path "HKCR:\LevythonScript\shell\open\command" -Name "(Default)" -Value "`"$targetExe`" `"%1`""
            
            # .ly extension
            New-Item -Path "HKCR:\.ly" -Force | Out-Null
            Set-ItemProperty -Path "HKCR:\.ly" -Name "(Default)" -Value "LevythonScript"
            
            Write-Log "File associations created" "SUCCESS"
        }
        catch {
            Write-Log "File association failed: $_" "WARN"
        }
    }
    
    # Create Start Menu shortcut
    if ($CreateShortcut) {
        try {
            $startMenu = [Environment]::GetFolderPath("CommonStartMenu")
            $shortcutPath = Join-Path $startMenu "Programs\Levython.lnk"
            
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $targetExe
            $shortcut.WorkingDirectory = $InstallPath
            $shortcut.Description = "Levython Programming Language"
            $shortcut.Save()
            
            Write-Log "Start Menu shortcut created" "SUCCESS"
        }
        catch {
            Write-Log "Shortcut creation failed: $_" "WARN"
        }
    }
    
    # Create uninstaller registry entry
    $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Levython"
    New-Item -Path $uninstallKey -Force | Out-Null
    Set-ItemProperty -Path $uninstallKey -Name "DisplayName" -Value "Levython $script:AppVersion"
    Set-ItemProperty -Path $uninstallKey -Name "DisplayVersion" -Value $script:AppVersion
    Set-ItemProperty -Path $uninstallKey -Name "Publisher" -Value "Levython Authors"
    Set-ItemProperty -Path $uninstallKey -Name "InstallLocation" -Value $InstallPath
    Set-ItemProperty -Path $uninstallKey -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$InstallPath\Uninstall.ps1`""
    Set-ItemProperty -Path $uninstallKey -Name "DisplayIcon" -Value "$targetExe,0"
    Set-ItemProperty -Path $uninstallKey -Name "NoModify" -Value 1 -Type DWord
    Set-ItemProperty -Path $uninstallKey -Name "NoRepair" -Value 1 -Type DWord
    
    # Copy uninstaller
    $uninstallerScript = @'
# Levython Uninstaller
$installDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Remove from PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
$paths = $currentPath -split ";" | Where-Object { $_ -ne $installDir -and $_ -ne "" }
[Environment]::SetEnvironmentVariable("Path", ($paths -join ";"), [EnvironmentVariableTarget]::Machine)

# Remove file associations
Remove-Item -Path "HKCR:\.levy" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKCR:\.ly" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKCR:\LevythonScript" -Recurse -Force -ErrorAction SilentlyContinue

# Remove Start Menu shortcut
$startMenu = [Environment]::GetFolderPath("CommonStartMenu")
Remove-Item -Path "$startMenu\Programs\Levython.lnk" -Force -ErrorAction SilentlyContinue

# Remove registry entry
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Levython" -Force -ErrorAction SilentlyContinue

# Remove installation directory
Start-Sleep -Seconds 1
Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue

[System.Windows.Forms.MessageBox]::Show("Levython has been uninstalled.", "Uninstall Complete", "OK", "Information")
'@
    
    $uninstallerPath = Join-Path $InstallPath "Uninstall.ps1"
    Set-Content -Path $uninstallerPath -Value $uninstallerScript
    
    Write-Log "Installation completed successfully!" "SUCCESS"
    return $true
}

# ============================================================================
# GUI INSTALLER
# ============================================================================
function Show-InstallerGUI {
    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Levython Installer"
    $form.Size = New-Object System.Drawing.Size(600, 560)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $form.ForeColor = [System.Drawing.Color]::White
    
    # Header Panel
    $headerPanel = New-Object System.Windows.Forms.Panel
    $headerPanel.Size = New-Object System.Drawing.Size(600, 100)
    $headerPanel.Location = New-Object System.Drawing.Point(0, 0)
    $headerPanel.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
    $form.Controls.Add($headerPanel)
    
    # Title Label
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "LEVYTHON"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = [System.Drawing.Color]::White
    $titleLabel.Location = New-Object System.Drawing.Point(20, 15)
    $titleLabel.AutoSize = $true
    $headerPanel.Controls.Add($titleLabel)
    
    # Subtitle Label
    $subtitleLabel = New-Object System.Windows.Forms.Label
    $subtitleLabel.Text = "High Performance Programming Language v$script:AppVersion"
    $subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
    $subtitleLabel.Location = New-Object System.Drawing.Point(25, 70)
    $subtitleLabel.AutoSize = $true
    $headerPanel.Controls.Add($subtitleLabel)
    
    # Architecture Label
    $archLabel = New-Object System.Windows.Forms.Label
    $archLabel.Text = "Detected: $script:Architecture"
    $archLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $archLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 255, 150)
    $archLabel.Location = New-Object System.Drawing.Point(450, 70)
    $archLabel.AutoSize = $true
    $headerPanel.Controls.Add($archLabel)
    
    # Installation Path Group
    $pathGroup = New-Object System.Windows.Forms.GroupBox
    $pathGroup.Text = "Installation Directory"
    $pathGroup.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $pathGroup.ForeColor = [System.Drawing.Color]::White
    $pathGroup.Size = New-Object System.Drawing.Size(550, 70)
    $pathGroup.Location = New-Object System.Drawing.Point(20, 115)
    $form.Controls.Add($pathGroup)
    
    $pathTextBox = New-Object System.Windows.Forms.TextBox
    $pathTextBox.Text = $script:InstallDir
    $pathTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $pathTextBox.Size = New-Object System.Drawing.Size(430, 25)
    $pathTextBox.Location = New-Object System.Drawing.Point(15, 30)
    $pathTextBox.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $pathTextBox.ForeColor = [System.Drawing.Color]::White
    $pathGroup.Controls.Add($pathTextBox)
    
    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Text = "Browse..."
    $browseButton.Size = New-Object System.Drawing.Size(85, 28)
    $browseButton.Location = New-Object System.Drawing.Point(450, 28)
    $browseButton.FlatStyle = "Flat"
    $browseButton.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $browseButton.ForeColor = [System.Drawing.Color]::White
    $browseButton.Add_Click({
            $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderDialog.Description = "Select installation directory"
            $folderDialog.SelectedPath = $pathTextBox.Text
            if ($folderDialog.ShowDialog() -eq "OK") {
                $pathTextBox.Text = $folderDialog.SelectedPath
            }
        })
    $pathGroup.Controls.Add($browseButton)
    
    # Options Group
    $optionsGroup = New-Object System.Windows.Forms.GroupBox
    $optionsGroup.Text = "Installation Options"
    $optionsGroup.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $optionsGroup.ForeColor = [System.Drawing.Color]::White
    $optionsGroup.Size = New-Object System.Drawing.Size(550, 245)
    $optionsGroup.Location = New-Object System.Drawing.Point(20, 195)
    $form.Controls.Add($optionsGroup)

    # Compiler label
    $lblCompiler = New-Object System.Windows.Forms.Label
    $lblCompiler.Text = "Select Compiler:"
    $lblCompiler.Location = New-Object System.Drawing.Point(15, 25)
    $lblCompiler.AutoSize = $true
    $optionsGroup.Controls.Add($lblCompiler)

    $rbMinGW = New-Object System.Windows.Forms.RadioButton
    $rbMinGW.Text = "MinGW (g++) — Recommended"
    $rbMinGW.Location = New-Object System.Drawing.Point(30, 45)
    $rbMinGW.AutoSize = $true
    $rbMinGW.Checked = $true
    $optionsGroup.Controls.Add($rbMinGW)

    $rbClang = New-Object System.Windows.Forms.RadioButton
    $rbClang.Text = "Clang (clang++) — Advanced / Fast"
    $rbClang.Location = New-Object System.Drawing.Point(30, 70)
    $rbClang.AutoSize = $true
    $optionsGroup.Controls.Add($rbClang)

    $rbMSVC = New-Object System.Windows.Forms.RadioButton
    $rbMSVC.Text = "Visual Studio (MSVC) — Experimental (may fail)"
    $rbMSVC.Location = New-Object System.Drawing.Point(30, 95)
    $rbMSVC.AutoSize = $true
    $optionsGroup.Controls.Add($rbMSVC)
    
    $chkPath = New-Object System.Windows.Forms.CheckBox
    $chkPath.Text = "Add Levython to system PATH (recommended)"
    $chkPath.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $chkPath.Size = New-Object System.Drawing.Size(500, 25)
    $chkPath.Location = New-Object System.Drawing.Point(15, 130)
    $chkPath.ForeColor = [System.Drawing.Color]::White
    $chkPath.Checked = $true
    $optionsGroup.Controls.Add($chkPath)
    
    $chkVSCode = New-Object System.Windows.Forms.CheckBox
    $chkVSCode.Text = "Install VS Code extension (syntax highlighting & snippets)"
    $chkVSCode.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $chkVSCode.Size = New-Object System.Drawing.Size(500, 25)
    $chkVSCode.Location = New-Object System.Drawing.Point(15, 155)
    $chkVSCode.ForeColor = [System.Drawing.Color]::White
    $chkVSCode.Checked = $true
    $optionsGroup.Controls.Add($chkVSCode)
    
    $chkAssociate = New-Object System.Windows.Forms.CheckBox
    $chkAssociate.Text = "Associate .levy and .ly files with Levython"
    $chkAssociate.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $chkAssociate.Size = New-Object System.Drawing.Size(500, 25)
    $chkAssociate.Location = New-Object System.Drawing.Point(15, 180)
    $chkAssociate.ForeColor = [System.Drawing.Color]::White
    $chkAssociate.Checked = $true
    $optionsGroup.Controls.Add($chkAssociate)
    
    $chkShortcut = New-Object System.Windows.Forms.CheckBox
    $chkShortcut.Text = "Create Start Menu shortcut"
    $chkShortcut.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $chkShortcut.Size = New-Object System.Drawing.Size(500, 25)
    $chkShortcut.Location = New-Object System.Drawing.Point(15, 205)
    $chkShortcut.ForeColor = [System.Drawing.Color]::White
    $chkShortcut.Checked = $true
    $optionsGroup.Controls.Add($chkShortcut)
    
    # Progress Bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(550, 25)
    $progressBar.Location = New-Object System.Drawing.Point(20, 360)
    $progressBar.Style = "Continuous"
    $progressBar.Visible = $false
    $form.Controls.Add($progressBar)
    
    # Status Label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = ""
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
    $statusLabel.Size = New-Object System.Drawing.Size(550, 20)
    $statusLabel.Location = New-Object System.Drawing.Point(20, 390)
    $form.Controls.Add($statusLabel)
    
    # Install Button
    $installButton = New-Object System.Windows.Forms.Button
    $installButton.Text = "Install"
    $installButton.Size = New-Object System.Drawing.Size(120, 40)
    $installButton.Location = New-Object System.Drawing.Point(340, 470)
    $installButton.FlatStyle = "Flat"
    $installButton.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
    $installButton.ForeColor = [System.Drawing.Color]::White
    $installButton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $installButton.Add_Click({
            if (-not (Test-Administrator)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Administrator privileges required. Please run as Administrator.",
                    "Privilege Required",
                    "OK",
                    "Warning"
                )
                return
            }
        
            $installButton.Enabled = $false
            $cancelButton.Enabled = $false
            $progressBar.Visible = $true
            $progressBar.Value = 0
        
            try {
                $statusLabel.Text = "Preparing installation..."
                $progressBar.Value = 10
                $form.Refresh()
            
                if ($rbMinGW.Checked) {
                    $script:CompilerChoice = "mingw"
                }
                elseif ($rbClang.Checked) {
                    $script:CompilerChoice = "clang"
                }
                elseif ($rbMSVC.Checked) {
                    $script:CompilerChoice = "msvc"
                }
                else {
                    throw "No compiler selected"
                }

                Write-Log "User selected compiler: $script:CompilerChoice"

                if ($script:CompilerChoice -eq "clang") {
                    Write-Log "Clang selected — ensure LLVM is installed and clang++ is in PATH" "INFO"
                }

                if ($script:CompilerChoice -eq "msvc") {
                    Write-Log "MSVC is experimental and may fail due to VM dispatch optimizations" "WARN"
                }

                $statusLabel.Text = "Installing Levython..."
                $progressBar.Value = 30
                $form.Refresh()
            
                Install-Levython `
                    -InstallPath $pathTextBox.Text `
                    -AddToPath $chkPath.Checked `
                    -InstallVSCode $chkVSCode.Checked `
                    -CreateShortcut $chkShortcut.Checked `
                    -AssociateFiles $chkAssociate.Checked
            
                $progressBar.Value = 100
                $statusLabel.Text = "Installation complete!"
            
                [System.Windows.Forms.MessageBox]::Show(
                    "Levython has been installed successfully!`n`nYou can now use 'levython' from any command prompt.`n`nCheck out the examples in:`n$($pathTextBox.Text)\examples",
                    "Installation Complete",
                    "OK",
                    "Information"
                )
            
                $form.Close()
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Installation failed: $_`n`nCheck the log file: $script:LogFile",
                    "Installation Error",
                    "OK",
                    "Error"
                )
                $installButton.Enabled = $true
                $cancelButton.Enabled = $true
                $progressBar.Visible = $false
            }
        })
    $form.Controls.Add($installButton)
    
    # Cancel Button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Size = New-Object System.Drawing.Size(100, 40)
    $cancelButton.Location = New-Object System.Drawing.Point(470, 470)
    $cancelButton.FlatStyle = "Flat"
    $cancelButton.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $cancelButton.ForeColor = [System.Drawing.Color]::White
    $cancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cancelButton.Add_Click({
            $form.Close()
        })
    $form.Controls.Add($cancelButton)
    
    # Footer
    $footerLabel = New-Object System.Windows.Forms.Label
    $footerLabel.Text = "© 2024-2026 Levython Authors | JIT-Compiled • Bytecode VM • Faster than C"
    $footerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $footerLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
    $footerLabel.Location = New-Object System.Drawing.Point(20, 445)
    $footerLabel.AutoSize = $true
    $form.Controls.Add($footerLabel)
    
    # Show form
    $form.ShowDialog() | Out-Null
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================
function Main {
    param(
        [switch]$Silent,
        [string]$InstallPath = $script:InstallDir
    )
    
    Write-Log "Levython Installer v$script:AppVersion" "INFO"
    Write-Log "Detected architecture: $script:Architecture" "INFO"
    
    if ($Silent) {
        # Silent installation
        if (-not (Test-Administrator)) {
            Write-Log "Administrator privileges required for silent installation" "ERROR"
            exit 1
        }
        
        try {
            Install-Levython -InstallPath $InstallPath
            exit 0
        }
        catch {
            Write-Log "Installation failed: $_" "ERROR"
            exit 1
        }
    }
    else {
        # GUI installation
        Show-InstallerGUI
    }
}

# Run installer
if ($args -contains "-Silent" -or $args -contains "--silent") {
    $installPath = $script:InstallDir
    for ($i = 0; $i -lt $args.Count; $i++) {
        if ($args[$i] -eq "-InstallPath" -or $args[$i] -eq "--install-path") {
            $installPath = $args[$i + 1]
        }
    }
    Main -Silent -InstallPath $installPath
}
else {
    Main
}
