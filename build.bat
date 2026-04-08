@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title Todo Schedule - Build
cd /d "%~dp0"

set "FLUTTER_LOCAL=%~dp0flutter_sdk"
set "FLUTTER_ZIP=%~dp0flutter_sdk.zip"
set "FLUTTER_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.3-stable.zip"

echo.
echo ============================================
echo   Todo Schedule - Build
echo ============================================
echo.

:: Check Flutter in PATH first, then local
call flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Flutter found in PATH
    call flutter --version
    goto flutter_ready
)

:: Check local Flutter SDK
if exist "%FLUTTER_LOCAL%\flutter\bin\flutter.bat" (
    echo [OK] Flutter found locally
    set "PATH=%FLUTTER_LOCAL%\flutter\bin;%PATH%"
    call flutter --version
    goto flutter_ready
)

:: Download Flutter SDK
echo [!] Flutter not found. Downloading Flutter SDK...
echo     This will take a few minutes (about 1.2 GB).
echo.

where curl >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] curl not found. Cannot download Flutter.
    echo         Install manually: https://docs.flutter.dev/get-started/install
    goto quit
)

echo [1/3] Downloading Flutter SDK...
curl -L -o "%FLUTTER_ZIP%" "%FLUTTER_URL%" --progress-bar
if %errorlevel% neq 0 (
    echo [ERROR] Download failed!
    if exist "%FLUTTER_ZIP%" del "%FLUTTER_ZIP%"
    goto quit
)

echo.
echo [2/3] Extracting (this may take a while)...
if not exist "%FLUTTER_LOCAL%" mkdir "%FLUTTER_LOCAL%"
powershell -Command "Expand-Archive -Path '%FLUTTER_ZIP%' -DestinationPath '%FLUTTER_LOCAL%' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] Extraction failed!
    goto quit
)

echo [3/3] Cleaning up...
del "%FLUTTER_ZIP%" 2>nul

set "PATH=%FLUTTER_LOCAL%\flutter\bin;%PATH%"
echo.
echo [*] Running flutter doctor...
call flutter doctor --android-licenses >nul 2>&1
call flutter doctor
echo.

:flutter_ready
echo.

:: Generate platform files if missing
if not exist "android" (
    echo [*] Generating platform files...
    call flutter create . --platforms=android,windows --org com.todo.schedule
    if %errorlevel% neq 0 (
        echo [ERROR] flutter create failed!
        goto quit
    )
    echo.
)

if not exist "windows" (
    echo [*] Generating Windows platform...
    call flutter create . --platforms=windows
    if %errorlevel% neq 0 (
        echo [ERROR] flutter create failed!
        goto quit
    )
    echo.
)

:: Install dependencies
echo [*] Installing dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies!
    goto quit
)
echo.
echo [OK] Ready!
echo.

:: Menu
:menu
echo.
echo ============================================
echo   Select action:
echo ============================================
echo   1 - Run on Windows
echo   2 - Build Windows (release)
echo   3 - Build APK (release)
echo   4 - Build App Bundle (release)
echo   5 - Run on Android (debug)
echo   6 - Exit
echo ============================================
set "choice="
set /p "choice=Your choice: "

if "%choice%"=="1" goto run_windows
if "%choice%"=="2" goto build_windows
if "%choice%"=="3" goto build_apk
if "%choice%"=="4" goto build_aab
if "%choice%"=="5" goto run_android
if "%choice%"=="6" goto quit

echo Invalid choice, try again.
goto menu

:run_windows
echo.
echo [*] Running on Windows...
call flutter run -d windows
pause
goto menu

:build_windows
echo.
echo [*] Building Windows (release)...
call flutter build windows --release
if %errorlevel% equ 0 (
    echo.
    echo [OK] Done! Files in:
    echo   build\windows\x64\runner\Release\
    start "" "build\windows\x64\runner\Release" 2>nul
) else (
    echo [ERROR] Build failed!
)
pause
goto menu

:build_apk
echo.
echo [*] Building APK (release)...
call flutter build apk --release
if %errorlevel% equ 0 (
    echo.
    echo [OK] Done! APK:
    echo   build\app\outputs\flutter-apk\app-release.apk
    start "" "build\app\outputs\flutter-apk" 2>nul
) else (
    echo [ERROR] Build failed!
)
pause
goto menu

:build_aab
echo.
echo [*] Building App Bundle (release)...
call flutter build appbundle --release
if %errorlevel% equ 0 (
    echo.
    echo [OK] Done! AAB:
    echo   build\app\outputs\bundle\release\app-release.aab
    start "" "build\app\outputs\bundle\release" 2>nul
) else (
    echo [ERROR] Build failed!
)
pause
goto menu

:run_android
echo.
echo [*] Running on Android (debug)...
call flutter run -d android
pause
goto menu

:quit
echo.
echo Press any key to exit...
pause >nul
endlocal
