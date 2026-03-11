@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cls
for /f "tokens=*" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "YELLOW=%ESC%[33m"
set "RESET=%ESC%[0m"
echo.
echo %CYAN%  Cloudflared Uninstall%RESET%
echo  -------------------------------------------------------------------------------
echo.
echo  %CYAN%[INFO]%RESET%  Killing cloudflared process...
taskkill /f /im cloudflared.exe >nul 2>&1
if !errorlevel! == 0 (
    echo  %YELLOW%[WARN]%RESET%  Existing cloudflared process killed.
) else (
    echo  %CYAN%[INFO]%RESET%  No running cloudflared process found.
)
echo.
echo  %CYAN%[INFO]%RESET%  Uninstalling via winget...
echo.
winget uninstall Cloudflare.cloudflared
if !errorlevel! == 0 (
    echo.
    echo  %GREEN%[OK]%RESET%    Cloudflared uninstalled successfully.
) else (
    echo.
    echo  %RED%[ERROR]%RESET% Uninstall failed or cloudflared was not installed.
)
echo.

:: -------------------------------------------------------
:: Clean up .token file if exists
:: -------------------------------------------------------
if exist "%~dp0.token" (
    del "%~dp0.token" >nul
    echo  %GREEN%[OK]%RESET%    .token file removed.
) else (
    echo  %CYAN%[INFO]%RESET%  No .token file found.
)

echo.
echo  -------------------------------------------------------------------------------
echo.
pause
endlocal