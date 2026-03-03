@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cls

for /f "tokens=*" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

set "TOKEN_FILE=%~dp0.token"
set "TOKEN_SAMPLE=eyJhIjoiMzZlNjE0YjkzM..."

echo.
echo %CYAN%  Cloudflared Tunnel Host %RESET%
echo  -------------------------------------------------------------------------------
echo.

:: -------------------------------------------------------
:: Kiem tra va khoi tao token file
:: -------------------------------------------------------
echo  %CYAN%[INFO]%RESET%  Kiem tra file token...
echo.

if not exist "%TOKEN_FILE%" (
    echo  %YELLOW%[SETUP]%RESET%  Tao file .token mau.
    echo.
    echo %TOKEN_SAMPLE%> "%TOKEN_FILE%"
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Mo file .token bang notepad:
    echo       %TOKEN_FILE%
    echo.
    echo    2. Xoa noi dung hien tai va dan token cloudflare tunnel cua ban
    echo       ^(Lay tu Cloudflare Zero Trust Dashboard^)
    echo.
    echo    3. Luu file va chay lai script nay.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 0
)

:: -------------------------------------------------------
:: Doc va xac thuc token
:: -------------------------------------------------------
echo  %CYAN%[INFO]%RESET%  Doc token tu file...
echo.

set /p TOKEN=<"%TOKEN_FILE%"

if "!TOKEN!"=="%TOKEN_SAMPLE%" (
    echo  %RED%[ERROR]%RESET%  Token khong hop le - vui long paste tunnel token cua ban vao .token
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Mo file .token bang notepad:
    echo       %TOKEN_FILE%
    echo.
    echo    2. Xoa noi dung mau va dan token cloudflare tunnel that cua ban.
    echo.
    echo    3. Luu file va chay lai script nay.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause & exit /b 1
)

if "!TOKEN!"=="" (
    echo  %RED%[ERROR]%RESET%  File .token rong.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Vui long nhap token vao file .token:
    echo    %TOKEN_FILE%
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause & exit /b 1
)

:: -------------------------------------------------------
:: Token hop le - Khoi dong Cloudflared
:: -------------------------------------------------------
del "%TOKEN_FILE%" >nul
echo  %GREEN%[OK]%RESET%    Token loaded and removed from disk.
echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %CYAN%[INFO]%RESET%  Starting Cloudflared Tunnel...
echo.

cloudflared tunnel run --token !TOKEN!

echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %RED%[STOP]%RESET%  Tunnel stopped.
echo.
endlocal
