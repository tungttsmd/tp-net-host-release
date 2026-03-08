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

set "GRANT_BAT=%~dp0passwd-granting.bat"
set "CONFIG_FILE=%~dp0.mosquitto-path"
set "CONF_FILE=%~dp0mosquitto.conf"
set "ACL_FILE=%~dp0acl"
set "PASSWD_FILE=%~dp0passwd"
set "PORT=1881"

echo.
echo %CYAN%  Mosquitto Launcher%RESET%
echo  -------------------------------------------------------------------------------
echo.

:: -------------------------------------------------------
:: Kiem tra duong dan co chua dau ngoac tron khong
:: -------------------------------------------------------
set "_PATH_CHECK=%~dp0"
if not "!_PATH_CHECK!"=="!_PATH_CHECK:(=!" goto :path_has_paren
if not "!_PATH_CHECK!"=="!_PATH_CHECK:)=!" goto :path_has_paren
goto :path_ok

:path_has_paren
echo  %RED%[ERROR]%RESET%  Duong dan chua dau ngoac tron: %~dp0
echo.
echo  -------------------------------------------------------------------------------
echo.
echo    Duong dan chua script khong duoc co dau ngoac tron ^( ^) o bat ky dau.
echo    Vi du loi: C:\Users\1\New folder ^(2^)\...
echo.
echo    Vui long di chuyen script den thu muc khong chua dau ngoac, sau do chay lai.
echo.
echo  -------------------------------------------------------------------------------
echo.
pause
exit /b 1

:path_ok

:: -------------------------------------------------------
:: Tu khoi tao cac file neu chua co
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
    echo.>> "%ACL_FILE%"
    echo # user: watcher>> "%ACL_FILE%"
    echo user watcher>> "%ACL_FILE%"
    echo topic readwrite winsv_wtpsvn/#>> "%ACL_FILE%"
    echo topic readwrite winsv_ftpsvn/#>> "%ACL_FILE%"
    echo topic readwrite winsv_atpsvn/#>> "%ACL_FILE%"
    echo topic readwrite winsv_ttpsvn/#>> "%ACL_FILE%"
    echo.>> "%ACL_FILE%"
    echo # user: facade>> "%ACL_FILE%"
    echo user facade>> "%ACL_FILE%"
    echo topic read winsv_wtpsvn/#>> "%ACL_FILE%"
    echo topic read winsv_ftpsvn/#>> "%ACL_FILE%"
    echo topic read winsv_atpsvn/#>> "%ACL_FILE%"
    echo topic read winsv_ttpsvn/#>> "%ACL_FILE%"
)

if not exist "%CONF_FILE%" (
    echo # Mosquitto Configuration> "!CONF_FILE!"
    echo.>> "!CONF_FILE!"
    echo listener 1881>> "!CONF_FILE!"
    echo bind_address 127.0.0.1>> "!CONF_FILE!"
    echo.>> "!CONF_FILE!"
    echo allow_anonymous true>> "!CONF_FILE!"
    echo password_file !PASSWD_FILE!>> "!CONF_FILE!"
    echo acl_file !ACL_FILE!>> "!CONF_FILE!"
)

if not exist "%CONFIG_FILE%" (
    echo Example: C:\Program Files\mosquitto\mosquitto.exe> "%CONFIG_FILE%"
)

:: -------------------------------------------------------
:: Hien thi trang thai cac file
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

:: -------------------------------------------------------
:: BUOC 1 - Kiem tra duong dan Mosquitto
:: -------------------------------------------------------
echo  %CYAN%[INFO]%RESET%  Buoc 1 - Kiem tra duong dan Mosquitto...
echo.

where mosquitto >nul 2>&1
if %ERRORLEVEL% == 0 (
    set "MOSQUITTO_EXE=mosquitto"
    echo  %GREEN%[DONE]%RESET%  Buoc 1 - Mosquitto tim thay trong PATH he thong.
    echo.
    goto :step2
)

set /p MOSQUITTO_EXE=<"%CONFIG_FILE%"

echo !MOSQUITTO_EXE! | findstr /i "^Example:" >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo  %YELLOW%[SETUP]%RESET%  Buoc 1 - Chua cau hinh duong dan Mosquitto.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Tai va cai dat Mosquitto phien ban 2.1.2 ^(x64^) hoac moi hon:
    echo       https://mosquitto.org/download/
    echo.
    echo    2. Mo file .mosquitto-path:
    echo       %CONFIG_FILE%
    echo.
    echo    3. Xoa toan bo noi dung va dan duong dan thuc toi mosquitto.exe
    echo       ^(Xoa ca chu "Example: " va thay bang duong dan that^)
    echo.
    echo       Example: C:\Program Files\mosquitto\mosquitto.exe
    echo.
    echo    4. Luu file va chay lai run.bat.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

if not exist "!MOSQUITTO_EXE!" (
    echo  %RED%[ERROR]%RESET%  Buoc 1 - Duong dan khong hop le: !MOSQUITTO_EXE!
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Kiem tra lai noi dung trong file .mosquitto-path:
    echo    %CONFIG_FILE%
    echo.
    echo    Example: C:\Program Files\mosquitto\mosquitto.exe
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Buoc 1 - Duong dan hop le: !MOSQUITTO_EXE!
echo.

:: -------------------------------------------------------
:: BUOC 2 - Kiem tra passwd
:: -------------------------------------------------------
:step2
echo  %CYAN%[INFO]%RESET%  Buoc 2 - Kiem tra file passwd...
echo.

if not exist "%PASSWD_FILE%" (
    echo  %YELLOW%[SETUP]%RESET%  Buoc 2 - Chua co file passwd.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    1. Mo cmd va tro toi thu muc cai dat Mosquitto ^(noi co mosquitto_passwd.exe^)
    echo.
    echo    2. Chay lenh sau va nhap password tao user admin khi duoc yeu cau:
    echo.
    echo  %GREEN%mosquitto_passwd -c "%PASSWD_FILE%" admin%RESET%
    echo.
    echo    3. Chay hai lenh sau de tao user watcher va facade ^(khong co lenh -c^):
    echo.
    echo  %GREEN%mosquitto_passwd "%PASSWD_FILE%" watcher%RESET%
    echo.
    echo  %GREEN%mosquitto_passwd "%PASSWD_FILE%" facade%RESET%
    echo.
    echo    4. Chay lai run.bat sau khi tao xong.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[DONE]%RESET%  Buoc 2 - File passwd ton tai.
echo.


:: -------------------------------------------------------
:: BUOC 3 - Kiem tra quyen Local System tren file passwd
:: -------------------------------------------------------
echo  %CYAN%[INFO]%RESET%  Buoc 3 - Kiem tra quyen Local System tren file passwd...
echo.
echo  %CYAN%[INFO]%RESET%  Buoc 3 - Quyen hien tai:
echo.
icacls "%~dp0passwd"
echo.
echo  %CYAN%[INFO]%RESET%  Buoc 3 - Xoa quyen cu neu co:
echo.
icacls "%~dp0passwd" /remove:g "NT AUTHORITY\SYSTEM"
echo.
echo  %CYAN%[INFO]%RESET%  Buoc 3 - Quyen sau khi xoa:
echo.
icacls "%~dp0passwd"
echo.
echo  %CYAN%[INFO]%RESET%  Buoc 3 - Ghi quyen LOCAL SYSTEM cho he thong:
echo.
icacls "%~dp0passwd" /grant "NT AUTHORITY\SYSTEM:(R)"
echo.
echo  %CYAN%[INFO]%RESET%  Buoc 3 - Quyen sau khi duoc cap lai:
echo.
icacls "%~dp0passwd"

if %ERRORLEVEL% NEQ 0 (
    echo  %RED%[ERROR]%RESET%  Cap quyen that bai. Chay lai voi quyen Administrator.
    echo.
    pause
    exit /b 1
)
echo.
echo  %GREEN%[DONE]%RESET%  Buoc 3 - Da ghi quyen cho Local System thanh cong.
echo.
goto :check_version

:: -------------------------------------------------------
:: Kiem tra phien ban
:: -------------------------------------------------------
:check_version

echo  %CYAN%[INFO]%RESET%  Kiem tra phien ban Mosquitto...
echo.

set "MOSQ_VER_TMP=%TEMP%\mosq_ver_%RANDOM%.txt"
"!MOSQUITTO_EXE!" --version 1>"%MOSQ_VER_TMP%" 2>&1

set "MOSQUITTO_VERSION="
for /f "usebackq tokens=3 delims= " %%v in ("%MOSQ_VER_TMP%") do (
    if "!MOSQUITTO_VERSION!"=="" set "MOSQUITTO_VERSION=%%v"
)
del "%MOSQ_VER_TMP%" >nul 2>&1

if "!MOSQUITTO_VERSION!"=="" (
    echo  %RED%[ERROR]%RESET%  Khong the kiem tra phien ban Mosquitto.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Dam bao duong dan trong .mosquitto-path tro dung toi mosquitto.exe
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
echo  %RED%[ERROR]%RESET%  Phien ban !MOSQUITTO_VERSION! khong du yeu cau ^(>= 2.1.2^)
echo.
echo  -------------------------------------------------------------------------------
echo.
echo    Tai tai : https://mosquitto.org/download/
echo    File    : mosquitto-2.1.2-install-windows-x64.exe
echo.
echo  -------------------------------------------------------------------------------
echo.
pause
exit /b 1

:: -------------------------------------------------------
:: Tat ca OK - Khoi dong Mosquitto
:: -------------------------------------------------------
:run
echo  %GREEN%[OK]%RESET%    Version  : !MOSQUITTO_VERSION!
echo  %GREEN%[OK]%RESET%    Path     : !MOSQUITTO_EXE!
echo  %GREEN%[OK]%RESET%    Config   : %CONF_FILE%
echo  %GREEN%[OK]%RESET%    ACL      : %ACL_FILE%
echo  %GREEN%[OK]%RESET%    Passwd   : %PASSWD_FILE%
echo.
echo  %CYAN%[INFO]%RESET%  Kiem tra port %PORT%...
echo.
set "PORT_BUSY=0"
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r ":%PORT% "') do set "PORT_PID=%%p" & set "PORT_BUSY=1"

if "!PORT_BUSY!"=="1" (
    set "PORT_PNAME=unknown"
    for /f "tokens=1 delims=," %%n in ('tasklist /fi "PID eq !PORT_PID!" /fo csv /nh 2^>nul') do set "PORT_PNAME=%%~n"
    echo  %RED%[ERROR]%RESET%  Port %PORT% dang bi chiem.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    echo    Process : !PORT_PNAME!
    echo    PID     : !PORT_PID!
    echo.
    echo    Tat process tren roi chay lai run.bat.
    echo.
    echo  -------------------------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

echo  %GREEN%[OK]%RESET%    Port %PORT% san sang.
echo.
echo  -------------------------------------------------------------------------------
echo.
echo  %CYAN%[INFO]%RESET%  Khoi dong Mosquitto...
echo.
"!MOSQUITTO_EXE!" -c "%CONF_FILE%" -v
endlocal
