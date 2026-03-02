@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION
cls

for /f "tokens=*" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

set "TOKEN_FILE=%~dp0.token"
set "TOKEN_SAMPLE=eyJhIjoiMzZlNjE0YjkzM..."

if not exist "%TOKEN_FILE%" (
    echo %TOKEN_SAMPLE%> "%TOKEN_FILE%"
    echo %GREEN%[SETUP]%RESET% Da tao file .token tai: %TOKEN_FILE%
    echo %GREEN%[SETUP]%RESET% Vui long edit file .token bang notepad (hoac bat ky trinh chinh sua nao^)
    echo %GREEN%[SETUP]%RESET% Thay noi dung bang token cloudflare tunnel thuc cua ban.
    echo %GREEN%[SETUP]%RESET% Sau do chay lai file nay.
    echo.
    pause
    exit /b 0
)

set /p TOKEN=<"%TOKEN_FILE%"

if "!TOKEN!"=="%TOKEN_SAMPLE%" (
    echo %RED%[ERROR]%RESET% Token khong hop le.
    echo %RED%[ERROR]%RESET% Vui long edit file .token bang notepad (hoac bat ky trinh chinh sua nao^)
    echo %RED%[ERROR]%RESET% Thay bang token tunnel cua ban roi chay lai.
    pause & exit /b 1
)

if "!TOKEN!"=="" (
    echo %RED%[ERROR]%RESET% File .token rong, vui long thay token vao roi chay lai.
    pause & exit /b 1
)

del "%TOKEN_FILE%" >nul
echo %CYAN%[INFO]%RESET% Service: host cloudflared service
echo %CYAN%[INFO]%RESET% Token loaded and removed from disk
echo.

cloudflared tunnel run --token %TOKEN%

echo.
echo %RED%[STOP]%RESET% Tunnel stopped.