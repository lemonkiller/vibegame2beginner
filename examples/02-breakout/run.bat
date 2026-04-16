@echo off
setlocal EnableDelayedExpansion

echo ===================================
echo    LOVE2D Game Launcher  
echo ===================================

set LOVE_VERSION=11.5
set LOVE_DIR=love-!LOVE_VERSION!-win64

set "SCRIPT_DIR=%~dp0"
set "GAME_DIR=%SCRIPT_DIR:~0,-1%"
set "PARENT_DIR=%GAME_DIR%\.."
set "FONT_DIR=%PARENT_DIR%\font"
set "CACHE_DIR=%PARENT_DIR%\.love-runtime"
set "LOVE_EXE=%CACHE_DIR%\%LOVE_DIR%\love.exe"
set "LOVE_ZIP=%CACHE_DIR%\%LOVE_DIR%.zip"
set "LOVE_URL=https://github.com/love2d/love/releases/download/!LOVE_VERSION!/love-!LOVE_VERSION!-win64.zip"

:: Create font symlink for the game
if not exist "%GAME_DIR%\font" (
    if exist "%FONT_DIR%" (
        mklink /J "%GAME_DIR%\font" "%FONT_DIR%" >nul 2>&1
    )
)

:: Check system PATH for love
where love >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] Using system LOVE
    pushd "%GAME_DIR%"
    love.exe .
    if errorlevel 1 pause
    popd
    exit /b 0
)

:: Check cache
if exist "%LOVE_EXE%" goto :RUN

:: Download love
echo [!] LOVE not found. Downloading...
echo     Cache: %CACHE_DIR%

if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

powershell -Command "Invoke-WebRequest -Uri '%LOVE_URL%' -OutFile '%LOVE_ZIP%' -UseBasicParsing" >nul 2>&1
if not exist "%LOVE_ZIP%" (
    echo [ERROR] Download failed
    pause
    exit /b 1
)

echo [OK] Downloaded. Extracting...

powershell -Command "Expand-Archive -Path '%LOVE_ZIP%' -DestinationPath '%CACHE_DIR%' -Force" >nul 2>&1
if not exist "%LOVE_EXE%" (
    echo [ERROR] Extraction failed
    pause
    exit /b 1
)

del "%LOVE_ZIP%"
echo [OK] Ready

:RUN
echo.
echo ===================================
echo    Starting game...  
echo ===================================
echo.

pushd "%GAME_DIR%"
"%LOVE_EXE%" .
if errorlevel 1 pause
popd

exit /b 0
