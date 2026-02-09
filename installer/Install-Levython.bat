@echo off
REM ============================================================================
REM LEVYTHON INSTALLER LAUNCHER
REM ============================================================================
REM This script launches the PowerShell GUI installer with admin privileges
REM ============================================================================

echo.
echo  ╔═══════════════════════════════════════════════════════════════════╗
echo  ║            LEVYTHON - Professional Windows Installer              ║
echo  ╠═══════════════════════════════════════════════════════════════════╣
echo  ║  High Performance Programming Language                            ║
echo  ║  Version: 1.0.2                                                   ║
echo  ║  Engine: JIT-Compiled Bytecode VM with NaN-boxing                 ║
echo  ╚═══════════════════════════════════════════════════════════════════╝
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo [*] Running installer...
echo.

REM Run the PowerShell installer
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0LevythonInstaller.ps1"

if %errorlevel% neq 0 (
    echo.
    echo [!] Installation encountered an error.
    echo [!] Check the log file in %%TEMP%%\levython-install.log
    pause
    exit /b 1
)

echo.
echo [+] Installation process completed.
echo.
pause
