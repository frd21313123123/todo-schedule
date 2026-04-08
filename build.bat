@echo off
setlocal
chcp 65001 >nul 2>&1
title Todo Schedule - Build
cd /d "%~dp0"

echo.
echo ============================================
echo   Todo Schedule - Сборка проекта
echo ============================================
echo.

:: Проверка Flutter
call flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Flutter не найден в PATH!
    echo.
    echo Установите Flutter SDK:
    echo   https://docs.flutter.dev/get-started/install
    echo.
    echo После установки добавьте путь к flutter\bin в PATH.
    goto :eof_pause
)

echo [OK] Flutter найден
call flutter --version
echo.

:: Генерация платформенных файлов если нет
if not exist "android" (
    echo [*] Генерация платформенных файлов...
    call flutter create . --platforms=android,windows --org com.todo.schedule
    if %errorlevel% neq 0 (
        echo [ОШИБКА] flutter create не удался!
        goto :eof_pause
    )
    echo.
)

if not exist "windows" (
    echo [*] Генерация Windows платформы...
    call flutter create . --platforms=windows
    if %errorlevel% neq 0 (
        echo [ОШИБКА] flutter create не удался!
        goto :eof_pause
    )
    echo.
)

:: Установка зависимостей
echo [*] Установка зависимостей...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ОШИБКА] Не удалось установить зависимости!
    goto :eof_pause
)
echo.
echo [OK] Всё готово!
echo.

:: Меню выбора
:menu
echo.
echo ============================================
echo   Выберите действие:
echo ============================================
echo   1 - Запустить на Windows
echo   2 - Собрать Windows (release)
echo   3 - Собрать APK (release)
echo   4 - Собрать App Bundle (release)
echo   5 - Запустить на Android (debug)
echo   6 - Выход
echo ============================================
set "choice="
set /p "choice=Ваш выбор: "

if "%choice%"=="1" goto run_windows
if "%choice%"=="2" goto build_windows
if "%choice%"=="3" goto build_apk
if "%choice%"=="4" goto build_aab
if "%choice%"=="5" goto run_android
if "%choice%"=="6" goto eof_pause

echo Неверный выбор, попробуйте снова.
goto menu

:run_windows
echo.
echo [*] Запуск на Windows...
call flutter run -d windows
pause
goto menu

:build_windows
echo.
echo [*] Сборка Windows (release)...
call flutter build windows --release
if %errorlevel% equ 0 (
    echo.
    echo [OK] Готово! Файлы в:
    echo   build\windows\x64\runner\Release\
    start "" "build\windows\x64\runner\Release" 2>nul
) else (
    echo [ОШИБКА] Сборка не удалась!
)
pause
goto menu

:build_apk
echo.
echo [*] Сборка APK (release)...
call flutter build apk --release
if %errorlevel% equ 0 (
    echo.
    echo [OK] Готово! APK:
    echo   build\app\outputs\flutter-apk\app-release.apk
    start "" "build\app\outputs\flutter-apk" 2>nul
) else (
    echo [ОШИБКА] Сборка не удалась!
)
pause
goto menu

:build_aab
echo.
echo [*] Сборка App Bundle (release)...
call flutter build appbundle --release
if %errorlevel% equ 0 (
    echo.
    echo [OK] Готово! AAB:
    echo   build\app\outputs\bundle\release\app-release.aab
    start "" "build\app\outputs\bundle\release" 2>nul
) else (
    echo [ОШИБКА] Сборка не удалась!
)
pause
goto menu

:run_android
echo.
echo [*] Запуск на Android (debug)...
call flutter run -d android
pause
goto menu

:eof_pause
echo.
echo Нажмите любую клавишу для выхода...
pause >nul
endlocal
