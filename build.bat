@echo off
setlocal
chcp 65001 >nul 2>&1
title Todo Schedule - Build
cd /d "%~dp0"

echo.
echo ============================================
echo   Todo Schedule - Build
echo ============================================
echo.

:: Check Flutter
call flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found in PATH!
    echo.
    echo Install Flutter SDK:
    echo   https://docs.flutter.dev/get-started/install
    echo.
    echo Then add flutter\bin to your PATH.
    goto quit
)

echo [OK] Flutter found
call flutter --version
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
