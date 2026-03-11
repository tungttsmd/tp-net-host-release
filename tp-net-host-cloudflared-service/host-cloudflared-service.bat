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

:: ============================================================
:: AUTO INSTALL CLOUDFLARED IF NOT FOUND
:: ============================================================
where cloudflared >nul 2>&1
if !errorlevel! neq 0 (
    echo  %YELLOW%[WARN]%RESET%  cloudflared not found. Installing via winget...
    echo.
    winget install Cloudflare.cloudflared
    if !errorlevel! neq 0 (
        echo.
        echo  %RED%[ERROR]%RESET% Install failed. Please install manually:
        echo          winget install Cloudflare.cloudflared
        echo.
        pause
        exit /b 1
    )
    echo.
    echo  %GREEN%[OK]%RESET%    Install complete!
    echo.
) else (
    echo  %GREEN%[OK]%RESET%    cloudflared found.
)

:: Find cloudflared path from registry (works even if PATH is not refreshed)
for /f "tokens=*" %%i in ('powershell -Command "[System.Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('PATH','User') | ForEach-Object { $_.Split(';') } | ForEach-Object { if (Test-Path \"$_\cloudflared.exe\") { \"$_\cloudflared.exe\" } }" 2^>nul') do set "CF_PATH=%%i"
if "!CF_PATH!"=="" (
    echo  %RED%[ERROR]%RESET% Cannot find cloudflared.exe path.
    pause
    exit /b 1
)
:: ============================================================

echo  %GREEN%[OK]%RESET%    Hostname   : %HOSTNAME%
echo  %GREEN%[OK]%RESET%    Local Port : %LOCAL_PORT%
echo  %GREEN%[OK]%RESET%    Path       : !CF_PATH!
echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %CYAN%[INFO]%RESET%  Checking for existing cloudflared process...
taskkill /f /im cloudflared.exe >nul 2>&1
if !errorlevel! == 0 (
    echo  %YELLOW%[WARN]%RESET%  Existing cloudflared process killed.
) else (
    echo  %CYAN%[INFO]%RESET%  No existing cloudflared process found.
)
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
