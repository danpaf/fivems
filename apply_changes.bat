@echo off
setlocal

:: SolarProject — Apply Changes Script
:: =====================================
:: 1. First clone the repo:  git clone --recursive https://github.com/citizenfx/fivem.git C:\SolarProject
:: 2. Then run this script:  apply_changes.bat C:\SolarProject
::
:: This copies all modified SolarProject files over the fresh clone.

set "TARGET=%~1"
if "%TARGET%"=="" (
    set /p TARGET="Enter path to fresh fivem clone (e.g. C:\SolarProject): "
)

if "%TARGET%"=="" (
    echo ERROR: No target path provided.
    pause
    exit /b 1
)

if not exist "%TARGET%\code\premake5.lua" (
    echo ERROR: %TARGET% does not look like a fivem repo (code\premake5.lua not found)
    pause
    exit /b 1
)

set "SRC=%~dp0"
echo.
echo Source (our changes): %SRC%
echo Target (fresh clone): %TARGET%
echo.

:: === Code changes ===
echo [1/14] LauncherConfig.h
copy /Y "%SRC%code\client\launcher\LauncherConfig.h" "%TARGET%\code\client\launcher\LauncherConfig.h"

echo [2/14] launcher.rc
copy /Y "%SRC%code\client\launcher\launcher.rc" "%TARGET%\code\client\launcher\launcher.rc"

echo [3/14] launcher.manifest
copy /Y "%SRC%code\client\launcher\launcher.manifest" "%TARGET%\code\client\launcher\launcher.manifest"

echo [4/14] Main.cpp (launcher)
copy /Y "%SRC%code\client\launcher\Main.cpp" "%TARGET%\code\client\launcher\Main.cpp"

echo [5/14] Bootstrap.cpp
copy /Y "%SRC%code\client\launcher\Bootstrap.cpp" "%TARGET%\code\client\launcher\Bootstrap.cpp"

echo [6/14] MiniDump.cpp
copy /Y "%SRC%code\client\launcher\MiniDump.cpp" "%TARGET%\code\client\launcher\MiniDump.cpp"

echo [7/14] Installer.cpp
copy /Y "%SRC%code\client\launcher\Installer.cpp" "%TARGET%\code\client\launcher\Installer.cpp"

echo [8/14] launcher premake5.lua + console premake5.lua
copy /Y "%SRC%code\client\launcher\premake5.lua" "%TARGET%\code\client\launcher\premake5.lua"
copy /Y "%SRC%code\client\console\premake5.lua" "%TARGET%\code\client\console\premake5.lua"

echo [9/14] Shared files (Utils.Win32.cpp, CfxSubProcess.h)
copy /Y "%SRC%code\client\shared\Utils.Win32.cpp" "%TARGET%\code\client\shared\Utils.Win32.cpp"
copy /Y "%SRC%code\client\shared\CfxSubProcess.h" "%TARGET%\code\client\shared\CfxSubProcess.h"

echo [10/14] Server files (server.rc, server premake5.lua)
copy /Y "%SRC%code\server\launcher\server.rc" "%TARGET%\code\server\launcher\server.rc"
copy /Y "%SRC%code\server\launcher\premake5.lua" "%TARGET%\code\server\launcher\premake5.lua"

echo [11/14] Components (RenderHooks, CustomText, GameInput, etc.)
copy /Y "%SRC%code\components\rage-graphics-five\src\RenderHooks.cpp" "%TARGET%\code\components\rage-graphics-five\src\RenderHooks.cpp"
copy /Y "%SRC%code\components\gta-core-five\src\CustomText.cpp" "%TARGET%\code\components\gta-core-five\src\CustomText.cpp"
copy /Y "%SRC%code\components\gta-core-five\src\GameInput.cpp" "%TARGET%\code\components\gta-core-five\src\GameInput.cpp"
copy /Y "%SRC%code\components\gta-core-five\src\PoolManagement.cpp" "%TARGET%\code\components\gta-core-five\src\PoolManagement.cpp"
copy /Y "%SRC%code\components\asi-five\src\Component.cpp" "%TARGET%\code\components\asi-five\src\Component.cpp"
copy /Y "%SRC%code\components\http-client\include\HttpClient.h" "%TARGET%\code\components\http-client\include\HttpClient.h"
copy /Y "%SRC%code\components\nui-gsclient\src\ServerList.cpp" "%TARGET%\code\components\nui-gsclient\src\ServerList.cpp"

echo [12/14] Server impl (InitConnectMethod, GameServer — license/heartbeat removal)
copy /Y "%SRC%code\components\citizen-server-impl\src\InitConnectMethod.cpp" "%TARGET%\code\components\citizen-server-impl\src\InitConnectMethod.cpp"
copy /Y "%SRC%code\components\citizen-server-impl\src\GameServer.cpp" "%TARGET%\code\components\citizen-server-impl\src\GameServer.cpp"

echo [13/14] Build scripts (premake5.lua, gen_rc.py)
copy /Y "%SRC%code\premake5.lua" "%TARGET%\code\premake5.lua"
copy /Y "%SRC%code\tools\gen_rc.py" "%TARGET%\code\tools\gen_rc.py"

echo [14/14] Data files (configs, launch scripts)
if not exist "%TARGET%\data\server_minimal" mkdir "%TARGET%\data\server_minimal"
if not exist "%TARGET%\data\client_minimal" mkdir "%TARGET%\data\client_minimal"
copy /Y "%SRC%data\server_minimal\*" "%TARGET%\data\server_minimal\"
copy /Y "%SRC%data\client_minimal\*" "%TARGET%\data\client_minimal\"

echo.
echo ========================================
echo All SolarProject changes applied!
echo ========================================
echo.
echo Next steps:
echo   cd %TARGET%\code
echo   tools\ci\premake5.exe vs2022 --game=server
echo   tools\ci\premake5.exe vs2022 --game=five
echo.
pause
