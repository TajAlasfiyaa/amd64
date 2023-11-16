@echo off
rem 生成时间 2023-11-16 08:46:31 UTC
:: @正义羊 翻译
:: 代理配置
:: 如果你需要配置一个代理服务器，以便能够连接到 Internet，
:: 那么你可以通过配置 all_proxy 环境变量来实现。
:: 默认情况下，此变量为空，即配置 aria2c 不使用任何代理。
::
:: 用法：set "all_proxy=proxy_address"
:: 示例：set "all_proxy=127.0.0.1:8888"
::
:: 有关如何使用的更多信息可以在以下网站找到：
:: https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-all-proxy
:: https://aria2.github.io/manual/en/html/aria2c.html#environment

:: 取消注释以下行以覆盖系统指定的代理设置。
:: 
::
:: set "all_proxy="

:: 代理配置结束

cd /d "%~dp0"
if NOT "%cd%"=="%cd: =%" (
    echo 当前目录的路径中含有空格或者括号。
    echo 请将此目录移动到或重命名为不含空格或括号的目录。
    echo.
    pause
    goto :EOF
)

if "[%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" goto :START_PROCESS
REG QUERY HKU\S-1-5-19\Environment >NUL 2>&1 && goto :START_PROCESS

set command="""%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547
SETLOCAL ENABLEDELAYEDEXPANSION
set "command=!command:'=''!"

powershell -NoProfile Start-Process -FilePath '%COMSPEC%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>NUL

IF %ERRORLEVEL% GTR 0 (
    echo =====================================================
    echo 此脚本需要以管理器权限执行。
    echo =====================================================
    echo.
    pause
)

SETLOCAL DISABLEDELAYEDEXPANSION
goto :EOF

:START_PROCESS
set "aria2=files\aria2c.exe"
set "a7z=files\7zr.exe"
set "uupConv=files\uup-converter-wimlib.7z"
set "aria2Script=files\aria2_script.%random%.txt"
set "destDir=UUPs"

powershell -NoProfile -ExecutionPolicy Unrestricted .\files\depends_win.ps1 || (pause & exit /b 1)
echo.

if NOT EXIST ConvertConfig.ini goto :NO_FILE_ERROR
if NOT EXIST %a7z% goto :NO_FILE_ERROR
if NOT EXIST %uupConv% goto :NO_FILE_ERROR

echo 正在解压 UUP 转换程序……
if NOT EXIST CustomAppsList.txt "%a7z%" -x!ConvertConfig.ini -y x "%uupConv%" >NUL
if EXIST CustomAppsList.txt "%a7z%" -x!ConvertConfig.ini -x!CustomAppsList.txt -y x "%uupConv%" >NUL
echo.




:DOWNLOAD_APPS
echo 正在检索适用于应用的 aria2 脚本……
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" -o"%aria2Script%" --allow-overwrite=true --auto-file-renaming=false "https://www.uupdump.cn/get.php?id=2d652122-0ea3-477a-9807-c8506fec8fc4&pack=neutral&edition=app&aria2=2"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1

for /F "tokens=2 delims=:" %%i in ('findstr #UUPDUMP_ERROR: "%aria2Script%"') do set DETECTED_ERROR=%%i
if NOT [%DETECTED_ERROR%] == [] (
    echo 无法从 Windows 更新服务器检索数据。原因：%DETECTED_ERROR%
    echo 如果此问题仍然存在，很可能你正在尝试下载的集已从 Windows 更新服务器中删除。
    echo.
    pause
    goto :EOF
)

echo 正在尝试下载应用文件……
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" -x16 -s16 -j25 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto :DOWNLOAD_APPS

:DOWNLOAD_UUPS
echo 正在检索 aria2 脚本……
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" -o"%aria2Script%" --allow-overwrite=true --auto-file-renaming=false "https://www.uupdump.cn/get.php?id=2d652122-0ea3-477a-9807-c8506fec8fc4&pack=en-us&edition=professional&aria2=2"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1
echo.

for /F "tokens=2 delims=:" %%i in ('findstr #UUPDUMP_ERROR: "%aria2Script%"') do set DETECTED_ERROR=%%i
if NOT [%DETECTED_ERROR%] == [] (
    echo 无法从 Windows 更新服务器检索数据。原因：%DETECTED_ERROR%
    echo 如果此问题仍然存在，很可能你正在尝试下载的集已从 Windows 更新服务器中删除。
    echo.
    pause
    goto :EOF
)

echo 正在尝试下载文件……
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" -x16 -s16 -j5 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto :DOWNLOAD_UUPS & exit /b 1
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" --allow-overwrite=true --auto-file-renaming=false -d"%destDir%" "https://www.uupdump.cn/get.php?id=2d652122-0ea3-477a-9807-c8506fec8fc4&pack=en-us&edition=professional&aria2=2&sha1=1"

if EXIST convert-UUP.cmd goto :START_CONVERT
pause
goto :EOF

:START_CONVERT
call convert-UUP.cmd
goto :EOF

:NO_FILE_ERROR
echo 我们找不到此脚本所需的文件之一。
pause
goto :EOF

:DOWNLOAD_ERROR
echo.
echo 我们在下载文件时遇到错误。
pause
goto :EOF

:EOF
