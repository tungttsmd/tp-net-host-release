@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f "tokens=*" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

set "CONFIG_FILE=%~dp0.redis-path"
set "CONF_FILE=%~dp0redis.conf"
set "PORT=6379"

:: ═══════════════════════════════════════════════════════════════════════════════
echo.
echo %CYAN%  Redis Environment%RESET%
echo  -------------------------------------------------------------------------------
:: ═══════════════════════════════════════════════════════════════════════════════

:: -------------------------------------------------------
:: Tự khởi tạo các file nếu chưa có
:: -------------------------------------------------------

if not exist "%CONF_FILE%" (
    echo # Redis Configuration> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo bind 127.0.0.1>> "%CONF_FILE%"
    echo port 6379>> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo # Tắt mode protected để cho phép kết nối từ localhost>> "%CONF_FILE%"
    echo protected-mode no>> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo # Log level: debug, verbose, notice, warning>> "%CONF_FILE%"
    echo loglevel notice>> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo # Không lưu snapshot (comment lại nếu muốn persistence)>> "%CONF_FILE%"
    echo # save 900 1>> "%CONF_FILE%"
    echo # save 300 10>> "%CONF_FILE%"
    echo # save 60 10000>> "%CONF_FILE%"
)

if not exist "%CONFIG_FILE%" (
    echo Example: C:\Program Files\Redis\redis-server.exe> "%CONFIG_FILE%"
)

:: -------------------------------------------------------
:: Hiển thị trạng thái các file
:: -------------------------------------------------------
echo.
echo  Files:
echo.

if exist "%CONF_FILE%"   ( echo  %GREEN%[OK]%RESET%      redis.conf   : %CONF_FILE%
) else ( echo  %RED%[MISSING]%RESET%  redis.conf   : %CONF_FILE% )

if exist "%CONFIG_FILE%" ( echo  %GREEN%[OK]%RESET%      .redis-path  : %CONFIG_FILE%
) else ( echo  %RED%[MISSING]%RESET%  .redis-path  : %CONFIG_FILE% )

echo.
echo  -------------------------------------------------------------------------------
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: BƯỚC 1 - Kiểm tra đường dẫn Redis
:: ═══════════════════════════════════════════════════════════════════════════════

echo  %CYAN%[INFO]%RESET%  Bước 1 - Kiểm tra đường dẫn Redis...
echo.

:: Ưu tiên PATH hệ thống
where redis-server >nul 2>&1
if %ERRORLEVEL% == 0 (
    set "REDIS_EXE=redis-server"
    echo  %GREEN%[DONE]%RESET%  Bước 1 - Redis tìm thấy trong PATH hệ thống.
    echo.
    goto :check_version
)

:: Đọc đường dẫn từ file
set /p REDIS_EXE=<"%CONFIG_FILE%"

:: Kiểm tra còn chứa chữ "Example:" là chưa cấu hình
echo !REDIS_EXE! | findstr /i "^Example:" >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  %YELLOW%[SETUP]%RESET%  Bước 1 - Chưa cấu hình đường dẫn Redis.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Tải và cài đặt Redis phiên bản 5.x hoặc mới hơn:
    echo       https://github.com/tporadowski/redis/releases (thời điểm tạo file này, git này đang mới nhất^)
    echo.
    echo    2. Mở file .redis-path tại vị trí cùng cấp với file run.bat:
    echo       %CONFIG_FILE%
    echo.
    echo    3. Xoá toàn bộ nội dung và dán đường dẫn thực tới redis-server.exe
    echo       ^(Xoá cả chữ "Example: " và thay bằng đường dẫn thật^)
    echo.
    echo    4. Lưu file và chạy lại run-redis.bat.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

:: Kiểm tra file có tồn tại không
if not exist "!REDIS_EXE!" (
    echo  %RED%[ERROR]%RESET%  Bước 1 - Đường dẫn không hợp lệ: !REDIS_EXE!
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Kiểm tra lại nội dung trong file .redis-path:
    echo    %CONFIG_FILE%
    echo.
    echo    Example: C:\Program Files\Redis\redis-server.exe
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Bước 1 - Đường dẫn hợp lệ: !REDIS_EXE!
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: Kiểm tra phiên bản
:: ═══════════════════════════════════════════════════════════════════════════════
:check_version
echo  %CYAN%[INFO]%RESET%  Kiểm tra phiên bản Redis...
echo.

set "REDIS_VER_TMP=%TEMP%\redis_ver_%RANDOM%.txt"
"!REDIS_EXE!" --version 1>"%REDIS_VER_TMP%" 2>&1

set "REDIS_VERSION="
for /f "usebackq tokens=3 delims= " %%v in ("%REDIS_VER_TMP%") do (
    if "!REDIS_VERSION!"=="" set "REDIS_VERSION=%%v"
)
del "%REDIS_VER_TMP%" >nul 2>&1

:: Cắt bỏ phần sau dấu space nếu có (ví dụ "v5.0.14.1" -> lấy số)
for /f "tokens=1 delims= " %%v in ("!REDIS_VERSION!") do set "REDIS_VERSION=%%v"

if "!REDIS_VERSION!"=="" (
    echo  %RED%[ERROR]%RESET%  Không thể kiểm tra phiên bản Redis.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Đảm bảo đường dẫn trong .redis-path trỏ đúng tới redis-server.exe
    echo    %CONFIG_FILE%
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Phiên bản Redis: !REDIS_VERSION!
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: Tất cả OK - Kiểm tra port rồi khởi động
:: ═══════════════════════════════════════════════════════════════════════════════
:run
echo  %GREEN%[OK]%RESET%    Version  : !REDIS_VERSION!
echo  %GREEN%[OK]%RESET%    Path     : !REDIS_EXE!
echo  %GREEN%[OK]%RESET%    Config   : %CONF_FILE%
echo.
echo  %CYAN%[INFO]%RESET%  Kiểm tra port %PORT%...
echo.

set "PORT_BUSY=0"
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r ":%PORT% "') do set "PORT_PID=%%p" & set "PORT_BUSY=1"

if "!PORT_BUSY!"=="1" (
    set "PORT_PNAME=unknown"
    for /f "tokens=1 delims=," %%n in ('tasklist /fi "PID eq !PORT_PID!" /fo csv /nh 2^>nul') do set "PORT_PNAME=%%~n"
    echo  %RED%[ERROR]%RESET%  Port %PORT% đang bị chiếm.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Process : !PORT_PNAME!
    echo    PID     : !PORT_PID!
    echo.
    echo    Tắt process trên rồi chạy lại run-redis.bat.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[OK]%RESET%    Port %PORT% sẵn sàng.
echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %CYAN%[INFO]%RESET%  Khởi động Redis...
echo.
"!REDIS_EXE!" "%CONF_FILE%"
endlocal