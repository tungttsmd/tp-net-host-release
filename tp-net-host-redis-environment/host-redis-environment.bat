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

set "CONFIG_FILE=%~dp0.redis-path"
set "CONF_FILE=%~dp0redis.conf"
set "PORT="

echo.
echo %CYAN%  Redis Launcher%RESET%
echo  -------------------------------------------------------------------------------
echo.

:: -------------------------------------------------------
:: Tu khoi tao cac file neu chua co
:: -------------------------------------------------------

if not exist "%CONF_FILE%" (
    echo # Redis Configuration> "%CONF_FILE%"
    echo bind 127.0.0.1>> "%CONF_FILE%"
    echo port 6379>> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo # protected-mode no: allow connections from localhost>> "%CONF_FILE%"
    echo protected-mode no>> "%CONF_FILE%"
    echo.>> "%CONF_FILE%"
    echo # Log level: debug, verbose, notice, warning>> "%CONF_FILE%"
    echo loglevel notice>> "%CONF_FILE%"
)

if not exist "%CONFIG_FILE%" (
    echo Example: C:\Program Files\Redis\redis-server.exe> "%CONFIG_FILE%"
)

:: -------------------------------------------------------
:: Hien thi trang thai cac file
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

:: -------------------------------------------------------
:: BUOC 1 - Kiem tra duong dan Redis
:: -------------------------------------------------------
echo  %CYAN%[INFO]%RESET%  Buoc 1 - Kiem tra duong dan Redis...
echo.

where redis-server >nul 2>&1
if %ERRORLEVEL% == 0 (
    set "REDIS_EXE=redis-server"
    echo  %GREEN%[DONE]%RESET%  Buoc 1 - Redis tim thay trong PATH he thong.
    echo.
    goto :check_version
)

set /p REDIS_EXE=<"%CONFIG_FILE%"

echo !REDIS_EXE! | findstr /i "^Example:" >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  %YELLOW%[SETUP]%RESET%  Buoc 1 - Chua cau hinh duong dan Redis.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Tai va cai dat Redis phien ban 5.x hoac moi hon:
    echo       https://github.com/tporadowski/redis/releases
    echo.
    echo    2. Mo file .redis-path tai vi tri cung cap voi file run.bat:
    echo       %CONFIG_FILE%
    echo.
    echo    3. Xoa toan bo noi dung va dan duong dan thuc toi redis-server.exe
    echo       ^(Xoa ca chu "Example: " va thay bang duong dan that^)
    echo.
    echo    4. Luu file va chay lai run-redis.bat.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

if not exist "!REDIS_EXE!" (
    echo  %RED%[ERROR]%RESET%  Buoc 1 - Duong dan khong hop le: !REDIS_EXE!
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Kiem tra lai noi dung trong file .redis-path:
    echo    %CONFIG_FILE%
    echo.
    echo    Example: C:\Program Files\Redis\redis-server.exe
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Buoc 1 - Duong dan hop le: !REDIS_EXE!
echo.

:: -------------------------------------------------------
:: Kiem tra phien ban
:: -------------------------------------------------------
:check_version
echo  %CYAN%[INFO]%RESET%  Kiem tra phien ban Redis...
echo.

set "REDIS_VER_TMP=%TEMP%\redis_ver_%RANDOM%.txt"
"!REDIS_EXE!" --version 1>"%REDIS_VER_TMP%" 2>&1

set "REDIS_VERSION="
for /f "usebackq tokens=3 delims= " %%v in ("%REDIS_VER_TMP%") do (
    if "!REDIS_VERSION!"=="" set "REDIS_VERSION=%%v"
)
del "%REDIS_VER_TMP%" >nul 2>&1

for /f "tokens=1 delims= " %%v in ("!REDIS_VERSION!") do set "REDIS_VERSION=%%v"

if "!REDIS_VERSION!"=="" (
    echo  %RED%[ERROR]%RESET%  Khong the kiem tra phien ban Redis.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Dam bao duong dan trong .redis-path tro dung toi redis-server.exe
    echo    %CONFIG_FILE%
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Phien ban Redis: !REDIS_VERSION!
echo.

:: -------------------------------------------------------
:: Doc port va host tu redis.conf
:: -------------------------------------------------------
set "HOST="
for /f "tokens=2" %%h in ('findstr /r "^bind " "%CONF_FILE%"') do set "HOST=%%h"
for /f "tokens=2" %%p in ('findstr /r "^port " "%CONF_FILE%"') do set "PORT=%%p"

if "!HOST!"=="" (
    set "HOST=127.0.0.1"
    echo  %YELLOW%[WARN]%RESET%  Khong tim thay bind trong redis.conf, su dung mac dinh 127.0.0.1
    echo.
)

if "!PORT!"=="" (
    set "PORT=6379"
    echo  %YELLOW%[WARN]%RESET%  Khong tim thay port trong redis.conf, su dung mac dinh 6379
    echo.
)

:: -------------------------------------------------------
:: Tat ca OK - Kiem tra port roi khoi dong
:: -------------------------------------------------------
:run
echo  %GREEN%[OK]%RESET%    Version  : !REDIS_VERSION!
echo  %GREEN%[OK]%RESET%    Path     : !REDIS_EXE!
echo  %GREEN%[OK]%RESET%    Config   : %CONF_FILE%
echo  %GREEN%[OK]%RESET%    Host     : !HOST!
echo  %GREEN%[OK]%RESET%    Port     : !PORT!
echo.
echo  %CYAN%[INFO]%RESET%  Kiem tra port !PORT!...
echo.

set "PORT_BUSY=0"
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r ":!PORT! "') do set "PORT_PID=%%p" & set "PORT_BUSY=1"

if "!PORT_BUSY!"=="1" (
    set "PORT_PNAME=unknown"
    for /f "tokens=1 delims=," %%n in ('tasklist /fi "PID eq !PORT_PID!" /fo csv /nh 2^>nul') do set "PORT_PNAME=%%~n"
    echo  %RED%[ERROR]%RESET%  Port !PORT! dang bi chiem.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Process : !PORT_PNAME!
    echo    PID     : !PORT_PID!
    echo.
    echo    Tat process tren roi chay lai run-redis.bat.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[OK]%RESET%    Port !PORT! san sang.
echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %CYAN%[INFO]%RESET%  Khoi dong Redis...
echo.
"!REDIS_EXE!" "%CONF_FILE%"
endlocal
