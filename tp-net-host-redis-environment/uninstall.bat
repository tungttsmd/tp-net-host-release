@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f "tokens=*" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

echo.
echo %YELLOW%[WARN]%RESET% Thao tác này sẽ xóa toàn bộ cấu hình Redis hiện tại:
echo          - .redis-path
echo          - redis.conf
echo.
echo %RED%[WARN]%RESET% Mosquitto sẽ không chạy được cho đến khi cấu hình lại!
echo.
set /p CONFIRM=Bạn có chắc chắn muốn tiếp tục? (yes/no) (y/n) (1/0): 
if /i "!CONFIRM!" neq "yes" if /i "!CONFIRM!" neq "y" if /i "!CONFIRM!" neq "1" (
    echo %CYAN%[INFO]%RESET% Đã hủy.
    pause
    exit /b 0
)

echo.
if exist "%~dp0.redis-path" (
    del "%~dp0.redis-path" >nul
    echo %GREEN%[OK]%RESET% Đã xóa .redis-path
)
if exist "%~dp0redis.conf" (
    del "%~dp0redis.conf" >nul
    echo %GREEN%[OK]%RESET% Đã xóa redis.conf
)

echo.
echo %GREEN%[DONE]%RESET% Đã xóa toàn bộ cấu hình. Chạy run.bat để thiết lập lại.
echo.
pause
endlocal