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
echo %CYAN%  Redis Reset%RESET%
echo  -------------------------------------------------------------------------------
echo.

echo  %YELLOW%[WARN]%RESET%  Thao tac nay se xoa toan bo cau hinh Redis hien tai:
echo.
echo          - .redis-path
echo          - redis.conf
echo.
echo  %RED%[WARN]%RESET%  Redis se khong chay duoc cho den khi cau hinh lai!
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

if exist "%~dp0.redis-path" (
    del "%~dp0.redis-path" >nul
    echo  %GREEN%[OK]%RESET%    Da xoa .redis-path
)
if exist "%~dp0redis.conf" (
    del "%~dp0redis.conf" >nul
    echo  %GREEN%[OK]%RESET%    Da xoa redis.conf
)

echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %GREEN%[DONE]%RESET%  Da xoa toan bo cau hinh. Chay run-redis.bat de thiet lap lai.
echo.
pause
endlocal
