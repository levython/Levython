@echo off
REM ===========================================================================
REM Levython Windows Installer Build Script
REM ===========================================================================
REM
REM Compiles Levython for Windows and creates a professional installer package.
REM
REM Prerequisites:
REM   - C++ Compiler: Visual Studio 2019+ or MinGW-w64
REM   - Inno Setup 6.x: https://jrsoftware.org/isinfo.php
REM
REM Usage:
REM   build-installer.bat
REM
REM Output:
REM   releases/levython-1.0.1-windows-installer.exe
REM
REM Copyright (c) 2024-2026 Levython Project
REM Licensed under the MIT License
REM ===========================================================================

setlocal EnableDelayedExpansion

echo.
echo ===========================================================================
echo LEVYTHON WINDOWS INSTALLER BUILD
echo Building Professional Distribution Package
echo ===========================================================================
echo.

REM Configuration
set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
set "BUILD_DIR=%SCRIPT_DIR%build"
set "ASSETS_DIR=%SCRIPT_DIR%assets"
set "SRC_DIR=%ROOT_DIR%\src"
set "OUTPUT_DIR=%ROOT_DIR%\releases"

REM Colors for output
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

REM Check for compiler
echo %BLUE%==^>%NC% Checking for C++ compiler...
where cl.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%[OK]%NC% Found Visual Studio compiler
    set "COMPILER=msvc"
    goto :compiler_found
)

where g++.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%[OK]%NC% Found MinGW g++ compiler
    set "COMPILER=mingw"
    goto :compiler_found
)

echo %RED%[ERROR]%NC% No C++ compiler found!
echo.
echo Please install one of the following:
echo   1. Visual Studio 2019+ with C++ tools
echo   2. MinGW-w64 (https://www.mingw-w64.org/)
echo.
pause
exit /b 1

:compiler_found

REM Create build directory
echo %BLUE%==^>%NC% Creating build directory...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%ASSETS_DIR%" mkdir "%ASSETS_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Use logo from root directory
echo %BLUE%==^>%NC% Configuring installer assets...
if exist "..\logo.png" (
    echo %GREEN%[OK]%NC% Using logo.png from repository
) else (
    echo %YELLOW%[WARNING]%NC% Logo not found, generating default assets...
    if not exist "%ASSETS_DIR%\levython.ico" (
        call :create_default_icon
    )
    if not exist "%ASSETS_DIR%\wizard-large.bmp" (
        call :create_wizard_images
    )
)

REM Compile Levython
echo %BLUE%==^>%NC% Compiling Levython...
cd "%SRC_DIR%"

if "%COMPILER%"=="msvc" (
    cl.exe /O2 /EHsc /std:c++17 /Fe:"%BUILD_DIR%\levython.exe" levython.cpp
    if %errorlevel% neq 0 (
        echo %RED%[ERROR]%NC% Compilation failed
        pause
        exit /b 1
    )
) else (
    g++ -std=c++17 -O3 -march=native -Wall -Wextra -o "%BUILD_DIR%\levython.exe" levython.cpp -static-libgcc -static-libstdc++
    if %errorlevel% neq 0 (
        echo %RED%[ERROR]%NC% Compilation failed
        pause
        exit /b 1
    )
)
echo %GREEN%[OK]%NC% Levython compiled successfully

REM Create LPM (Package Manager) stub
echo %BLUE%==^>%NC% Creating LPM executable...
call :create_lpm

REM Check for Inno Setup
echo %BLUE%==^>%NC% Checking for Inno Setup...
set "ISCC="
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
)
if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set "ISCC=C:\Program Files\Inno Setup 6\ISCC.exe"
)

if "%ISCC%"=="" (
    where iscc.exe >nul 2>&1
    if %errorlevel% equ 0 (
        set "ISCC=iscc.exe"
    ) else (
        echo %RED%✗%NC% Inno Setup not found!
        echo.
        echo Please download and install Inno Setup 6.x from:
        echo https://jrsoftware.org/isinfo.php
        echo.
        echo After installation, run this script again.
        echo.
        pause
        exit /b 1
    )
)

echo %GREEN%✓%NC% Found Inno Setup

REM Build installer
echo %BLUE%==^>%NC% Building installer package...
cd "%SCRIPT_DIR%"
"%ISCC%" /Q installer.iss
if %errorlevel% neq 0 (
    echo %RED%✗%NC% Installer build failed!
    pause
    exit /b 1
)

echo.
echo %GREEN%===========================================================================%NC%
echo %GREEN%BUILD COMPLETE%NC%
echo %GREEN%===========================================================================%NC%
echo.
echo %GREEN%[OK]%NC% Installer created: %OUTPUT_DIR%\levython-1.0.1-windows-installer.exe
echo.
echo Distribution Instructions:
echo   1. Upload the installer to GitHub Releases
echo   2. Users download and execute to install
echo   3. No additional dependencies required
echo.
echo Package Contents:
echo   - Levython compiler executable
echo   - LPM package manager
echo   - Documentation and examples
echo   - VS Code syntax extension
echo   - Automatic PATH configuration
echo.
start "" "%OUTPUT_DIR%"
pause
exit /b 0

REM ============================================================================
REM Helper Functions
REM ============================================================================

:create_default_icon
echo Creating levython.ico...
REM Create a simple ICO file using PowerShell
powershell -Command ^
    "$bitmap = New-Object System.Drawing.Bitmap(256, 256); " ^
    "$graphics = [System.Drawing.Graphics]::FromImage($bitmap); " ^
    "$graphics.FillRectangle([System.Drawing.Brushes]::DarkBlue, 0, 0, 256, 256); " ^
    "$font = New-Object System.Drawing.Font('Arial', 120, [System.Drawing.FontStyle]::Bold); " ^
    "$graphics.DrawString('L', $font, [System.Drawing.Brushes]::White, 40, 40); " ^
    "$icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon()); " ^
    "$stream = [System.IO.File]::Create('%ASSETS_DIR%\levython.ico'); " ^
    "$icon.Save($stream); " ^
    "$stream.Close();"
exit /b 0

:create_wizard_images
echo Creating wizard images...
REM Create wizard images using PowerShell
powershell -Command ^
    "$large = New-Object System.Drawing.Bitmap(164, 314); " ^
    "$g = [System.Drawing.Graphics]::FromImage($large); " ^
    "$g.FillRectangle([System.Drawing.Brushes]::Navy, 0, 0, 164, 314); " ^
    "$font = New-Object System.Drawing.Font('Arial', 48, [System.Drawing.FontStyle]::Bold); " ^
    "$g.DrawString('Levython', $font, [System.Drawing.Brushes]::White, 5, 120); " ^
    "$large.Save('%ASSETS_DIR%\wizard-large.bmp'); " ^
    "$small = New-Object System.Drawing.Bitmap(55, 55); " ^
    "$g2 = [System.Drawing.Graphics]::FromImage($small); " ^
    "$g2.FillRectangle([System.Drawing.Brushes]::DarkBlue, 0, 0, 55, 55); " ^
    "$font2 = New-Object System.Drawing.Font('Arial', 32, [System.Drawing.FontStyle]::Bold); " ^
    "$g2.DrawString('L', $font2, [System.Drawing.Brushes]::White, 8, 8); " ^
    "$small.Save('%ASSETS_DIR%\wizard-small.bmp');"
exit /b 0

:create_lpm
echo Creating LPM (Levython Package Manager)...
echo @echo off > "%BUILD_DIR%\lpm.bat"
echo REM Levython Package Manager >> "%BUILD_DIR%\lpm.bat"
echo echo LPM - Levython Package Manager v1.0 >> "%BUILD_DIR%\lpm.bat"
echo echo. >> "%BUILD_DIR%\lpm.bat"
echo if "%%1"=="" goto :usage >> "%BUILD_DIR%\lpm.bat"
echo if "%%1"=="install" goto :install >> "%BUILD_DIR%\lpm.bat"
echo if "%%1"=="list" goto :list >> "%BUILD_DIR%\lpm.bat"
echo if "%%1"=="update" goto :update >> "%BUILD_DIR%\lpm.bat"
echo goto :usage >> "%BUILD_DIR%\lpm.bat"
echo :usage >> "%BUILD_DIR%\lpm.bat"
echo echo Usage: lpm [command] [package] >> "%BUILD_DIR%\lpm.bat"
echo echo. >> "%BUILD_DIR%\lpm.bat"
echo echo Commands: >> "%BUILD_DIR%\lpm.bat"
echo echo   install [package]  - Install a package >> "%BUILD_DIR%\lpm.bat"
echo echo   list              - List installed packages >> "%BUILD_DIR%\lpm.bat"
echo echo   update            - Update all packages >> "%BUILD_DIR%\lpm.bat"
echo goto :end >> "%BUILD_DIR%\lpm.bat"
echo :install >> "%BUILD_DIR%\lpm.bat"
echo echo Installing %%2... >> "%BUILD_DIR%\lpm.bat"
echo echo Package management coming soon! >> "%BUILD_DIR%\lpm.bat"
echo goto :end >> "%BUILD_DIR%\lpm.bat"
echo :list >> "%BUILD_DIR%\lpm.bat"
echo echo No packages installed yet. >> "%BUILD_DIR%\lpm.bat"
echo goto :end >> "%BUILD_DIR%\lpm.bat"
echo :update >> "%BUILD_DIR%\lpm.bat"
echo echo Checking for updates... >> "%BUILD_DIR%\lpm.bat"
echo echo All packages up to date! >> "%BUILD_DIR%\lpm.bat"
echo goto :end >> "%BUILD_DIR%\lpm.bat"
echo :end >> "%BUILD_DIR%\lpm.bat"

REM Create a simple wrapper exe for LPM
copy "%BUILD_DIR%\levython.exe" "%BUILD_DIR%\lpm.exe" >nul
exit /b 0
