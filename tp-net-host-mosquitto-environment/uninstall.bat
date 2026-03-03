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

echo.
echo %CYAN%  Mosquitto Reset%RESET%
echo  -------------------------------------------------------------------------------
echo.

echo  %YELLOW%[WARN]%RESET%  Thao tac nay se xoa toan bo cau hinh Mosquitto hien tai:
echo.
echo          - .mosquitto-path
echo          - mosquitto.conf
echo          - acl
echo          - passwd
echo.
echo  %RED%[WARN]%RESET%  Mosquitto se khong chay duoc cho den khi cau hinh lai!
echo.
set /p CONFIRM=  Ban co chac chan muon tiep tuc? (yes/no) (y/n) (1/0): 

if /i "!CONFIRM!" neq "yes" if /i "!CONFIRM!" neq "y" if /i "!CONFIRM!" neq "1" (
    echo.
    echo  %CYAN%[INFO]%RESET%  Da huy.
    echo.
    pause
    exit /b 0
)

echo.
echo  -------------------------------------------------------------------------------
echo.

if exist "%~dp0.mosquitto-path" (
    del "%~dp0.mosquitto-path" >nul
    echo  %GREEN%[OK]%RESET%    Da xoa .mosquitto-path
)
if exist "%~dp0mosquitto.conf" (
    del "%~dp0mosquitto.conf" >nul
    echo  %GREEN%[OK]%RESET%    Da xoa mosquitto.conf
)
if exist "%~dp0acl" (
    del "%~dp0acl" >nul
    echo  %GREEN%[OK]%RESET%    Da xoa acl
)
if exist "%~dp0passwd" (
    del "%~dp0passwd" >nul
    echo  %GREEN%[OK]%RESET%    Da xoa passwd
)

echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %GREEN%[DONE]%RESET%  Da xoa toan bo cau hinh. Chay run.bat de thiet lap lai.
echo.
pause
endlocal
