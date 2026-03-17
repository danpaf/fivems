@echo off
setlocal

:: SolarProject Server Launcher
:: Starts the server on port 30120 (LAN mode)

set "SERVER_DIR=%~dp0"
set "SERVER_EXE=%SERVER_DIR%SolarServer.exe"

if not exist "%SERVER_EXE%" (
    echo ERROR: SolarServer.exe not found in %SERVER_DIR%
    echo Make sure you built the project and copied the output here.
    pause
    exit /b 1
)

:: Use our minimal components list
if exist "%SERVER_DIR%components.json" (
    echo Using minimal components.json
) else (
    echo WARNING: components.json not found, server may load unnecessary components.
)

echo Starting SolarProject Server...
echo Config: %SERVER_DIR%server.cfg
echo.

"%SERVER_EXE%" +exec "%SERVER_DIR%server.cfg"
