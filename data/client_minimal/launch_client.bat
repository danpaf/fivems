@echo off
setlocal

:: SolarProject Client Launcher
:: Usage: launch_client.bat [server_ip:port]
:: Example: launch_client.bat 192.168.1.100:30120

set "SERVER=%~1"
if "%SERVER%"=="" (
    set /p SERVER="Enter server IP:port (e.g. 192.168.1.100:30120): "
)

if "%SERVER%"=="" (
    echo ERROR: No server address provided.
    pause
    exit /b 1
)

:: Find SolarProject client exe (built output)
set "CLIENT_DIR=%~dp0"
set "CLIENT_EXE=%CLIENT_DIR%SolarProject.exe"

if not exist "%CLIENT_EXE%" (
    echo ERROR: SolarProject.exe not found in %CLIENT_DIR%
    echo Make sure you built the project and copied the output here.
    pause
    exit /b 1
)

:: Ensure .formaldev file exists (enables devMode, skips bootstrap/updates)
if not exist "%CLIENT_EXE%.formaldev" (
    echo. > "%CLIENT_EXE%.formaldev"
    echo Created .formaldev file for devMode.
)

:: Launch with direct connect
echo Connecting to %SERVER%...
start "" "%CLIENT_EXE%" +connect %SERVER%
