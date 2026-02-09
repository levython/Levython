@echo off
REM Simple build script that refreshes PATH and uses MinGW
echo Refreshing environment PATH...
call refreshenv 2>nul

echo.
echo Checking for g++...
where g++ 2>nul
if %errorlevel% neq 0 (
    echo ERROR: g++ not found in PATH
    echo.
    echo Adding Scoop to PATH...
    set PATH=%USERPROFILE%\scoop\shims;%PATH%
    where g++ 2>nul
    if %errorlevel% neq 0 (
        echo ERROR: Still can't find g++. Please install MinGW via: scoop install mingw
        pause
        exit /b 1
    )
)

echo.
echo Found g++ at:
where g++

echo.
echo Running PowerShell installer...
powershell -ExecutionPolicy Bypass -Command "$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User'); & '.\LevythonInstaller.ps1'"

pause
