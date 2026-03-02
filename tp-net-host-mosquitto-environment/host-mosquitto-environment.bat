@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f "tokens=*" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

set "CONFIG_FILE=%~dp0.mosquitto-path"
set "CONF_FILE=%~dp0mosquitto.conf"
set "ACL_FILE=%~dp0acl"
set "PASSWD_FILE=%~dp0passwd"
set "PORT=1881"

:: ═══════════════════════════════════════════════════════════════════════════════
echo.
echo %CYAN%  Mosquitto Launcher%RESET%
echo  -------------------------------------------------------------------------------
:: ═══════════════════════════════════════════════════════════════════════════════

:: -------------------------------------------------------
:: Tự khởi tạo các file nếu chưa có
:: -------------------------------------------------------

if not exist "%ACL_FILE%" (
    echo # ACL - Access Control List> "%ACL_FILE%"
    echo.>> "%ACL_FILE%"
    echo # Anonymous: write only>> "%ACL_FILE%"
    echo topic write winsv_wtpsvn/#>> "%ACL_FILE%"
    echo topic write winsv_ftpsvn/#>> "%ACL_FILE%"
    echo.>> "%ACL_FILE%"
    echo # Anonymous: read only>> "%ACL_FILE%"
    echo topic read winsv_atpsvn/+/control>> "%ACL_FILE%"
    echo topic read winsv_ttpsvn/+/control>> "%ACL_FILE%"
    echo.>> "%ACL_FILE%"
    echo # user: admin>> "%ACL_FILE%"
    echo user admin>> "%ACL_FILE%"
    echo topic readwrite #>> "%ACL_FILE%"
)

if not exist "%CONF_FILE%" (
    echo # Mosquitto Configuration> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo listener 1881>> "%CONF_FILE%"
    echo bind_address 127.0.0.1>> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo allow_anonymous true>> "%CONF_FILE%"
    echo password_file %PASSWD_FILE%>> "%CONF_FILE%"
    echo acl_file %ACL_FILE%>> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo # log_type all>> "%CONF_FILE%"
)

if not exist "%CONFIG_FILE%" (
    echo Example: C:\Program Files\mosquitto\mosquitto.exe> "%CONFIG_FILE%"
)

:: -------------------------------------------------------
:: Hiển thị trạng thái các file
:: -------------------------------------------------------
echo.
echo  Files:
echo.

if exist "%ACL_FILE%"    ( echo  %GREEN%[OK]%RESET%      acl             : %ACL_FILE%
) else ( echo  %RED%[MISSING]%RESET%  acl             : %ACL_FILE% )

if exist "%CONF_FILE%"   ( echo  %GREEN%[OK]%RESET%      mosquitto.conf  : %CONF_FILE%
) else ( echo  %RED%[MISSING]%RESET%  mosquitto.conf  : %CONF_FILE% )

if exist "%CONFIG_FILE%" ( echo  %GREEN%[OK]%RESET%      .mosquitto-path : %CONFIG_FILE%
) else ( echo  %RED%[MISSING]%RESET%  .mosquitto-path : %CONFIG_FILE% )

if exist "%PASSWD_FILE%" ( echo  %GREEN%[OK]%RESET%      passwd          : %PASSWD_FILE%
) else ( echo  %YELLOW%[PENDING]%RESET%  passwd          : %PASSWD_FILE% )

echo.
echo  -------------------------------------------------------------------------------
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: BƯỚC 1 - Kiểm tra đường dẫn Mosquitto
:: ═══════════════════════════════════════════════════════════════════════════════

echo  %CYAN%[INFO]%RESET%  Bước 1 - Kiểm tra đường dẫn Mosquitto...
echo.

:: Ưu tiên PATH hệ thống
where mosquitto >nul 2>&1
if %ERRORLEVEL% == 0 (
    set "MOSQUITTO_EXE=mosquitto"
    echo  %GREEN%[DONE]%RESET%  Bước 1 - Mosquitto tìm thấy trong PATH hệ thống.
    echo.
    goto :step2
)

:: Đọc đường dẫn từ file
set /p MOSQUITTO_EXE=<"%CONFIG_FILE%"

:: Kiểm tra còn chứa chữ "Example:" là chưa cấu hình
echo !MOSQUITTO_EXE! | findstr /i "^Example:" >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  %YELLOW%[SETUP]%RESET%  Bước 1 - Chưa cấu hình đường dẫn Mosquitto.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Tải và cài đặt Mosquitto phiên bản 2.1.2 ^(x64^) hoặc mới hơn:
    echo       https://mosquitto.org/download/
    echo.
    echo    2. Mở file .mosquitto-path:
    echo       %CONFIG_FILE%
    echo.
    echo    3. Xoá toàn bộ nội dung và dán đường dẫn thực tới mosquitto.exe
    echo       ^(Xoá cả chữ "Example: " và thay bằng đường dẫn thật^)
    echo.
    echo       Example: C:\Program Files\mosquitto\mosquitto.exe
    echo.
    echo    4. Lưu file và chạy lại run.bat.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

:: Kiểm tra file có tồn tại không
if not exist "!MOSQUITTO_EXE!" (
    echo  %RED%[ERROR]%RESET%  Bước 1 - Đường dẫn không hợp lệ: !MOSQUITTO_EXE!
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Kiểm tra lại nội dung trong file .mosquitto-path:
    echo    %CONFIG_FILE%
    echo.
    echo    Example: C:\Program Files\mosquitto\mosquitto.exe
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Bước 1 - Đường dẫn hợp lệ: !MOSQUITTO_EXE!
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: BƯỚC 2 - Kiểm tra passwd
:: ═══════════════════════════════════════════════════════════════════════════════
:step2
echo  %CYAN%[INFO]%RESET%  Bước 2 - Kiểm tra file passwd...
echo.

if not exist "%PASSWD_FILE%" (
    echo  %YELLOW%[SETUP]%RESET%  Bước 2 - Chưa có file passwd.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Mở cmd và trỏ tới thư mục cài đặt Mosquitto ^(nơi có mosquitto_passwd.exe^)
    echo.
    echo    2. Chạy lệnh sau và nhập password khi được yêu cầu:
    echo.
    echo       %GREEN%mosquitto_passwd -c "%PASSWD_FILE%" admin%RESET%
    echo.
    echo    3. Chạy lại run.bat sau khi tạo xong.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Bước 2 - File passwd tồn tại.
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: Kiểm tra phiên bản
:: ═══════════════════════════════════════════════════════════════════════════════
echo  %CYAN%[INFO]%RESET%  Kiểm tra phiên bản Mosquitto...
echo.

:: Ghi stdout+stderr ra file tạm, đọc dòng chứa "version"
set "MOSQ_VER_TMP=%TEMP%\mosq_ver_%RANDOM%.txt"
"!MOSQUITTO_EXE!" --version 1>"%MOSQ_VER_TMP%" 2>&1

set "MOSQUITTO_VERSION="
for /f "usebackq tokens=3 delims= " %%v in ("%MOSQ_VER_TMP%") do (
    if "!MOSQUITTO_VERSION!"=="" set "MOSQUITTO_VERSION=%%v"
)
del "%MOSQ_VER_TMP%" >nul 2>&1

if "!MOSQUITTO_VERSION!"=="" (
    echo  %RED%[ERROR]%RESET%  Không thể kiểm tra phiên bản Mosquitto.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Đảm bảo đường dẫn trong .mosquitto-path trỏ đúng tới mosquitto.exe
    echo    %CONFIG_FILE%
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

for /f "tokens=1,2 delims=." %%a in ("!MOSQUITTO_VERSION!") do (
    set "VER_MAJOR=%%a"
    set "VER_MINOR=%%b"
)

if !VER_MAJOR! LSS 2 goto :ver_error
if !VER_MAJOR! EQU 2 if !VER_MINOR! LSS 1 goto :ver_error
goto :run

:ver_error
echo  %RED%[ERROR]%RESET%  Phiên bản !MOSQUITTO_VERSION! không đủ yêu cầu ^(>= 2.1.2^)
echo.
echo  -------------------------------------------------------------------------------
echo.
echo    Tải tại : https://mosquitto.org/download/
echo    File    : mosquitto-2.1.2-install-windows-x64.exe
echo.
echo  -------------------------------------------------------------------------------
echo.
pause
exit /b 1

:: ═══════════════════════════════════════════════════════════════════════════════
:: Tất cả OK - Khởi động Mosquitto
:: ═══════════════════════════════════════════════════════════════════════════════
:run
echo  %GREEN%[OK]%RESET%    Version  : !MOSQUITTO_VERSION!
echo  %GREEN%[OK]%RESET%    Path     : !MOSQUITTO_EXE!
echo  %GREEN%[OK]%RESET%    Config   : %CONF_FILE%
echo  %GREEN%[OK]%RESET%    ACL      : %ACL_FILE%
echo  %GREEN%[OK]%RESET%    Passwd   : %PASSWD_FILE%
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
    echo    Tắt process trên rồi chạy lại run.bat.
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
echo  %CYAN%[INFO]%RESET%  Khởi động Mosquitto...
echo.
"!MOSQUITTO_EXE!" -c "%CONF_FILE%" -v
endlocal