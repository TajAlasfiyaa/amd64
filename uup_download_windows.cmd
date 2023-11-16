@echo off
rem ����ʱ�� 2023-11-16 08:46:31 UTC
:: @������ ����
:: ��������
:: �������Ҫ����һ��������������Ա��ܹ����ӵ� Internet��
:: ��ô�����ͨ������ all_proxy ����������ʵ�֡�
:: Ĭ������£��˱���Ϊ�գ������� aria2c ��ʹ���κδ���
::
:: �÷���set "all_proxy=proxy_address"
:: ʾ����set "all_proxy=127.0.0.1:8888"
::
:: �й����ʹ�õĸ�����Ϣ������������վ�ҵ���
:: https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-all-proxy
:: https://aria2.github.io/manual/en/html/aria2c.html#environment

:: ȡ��ע���������Ը���ϵͳָ���Ĵ������á�
:: 
::
:: set "all_proxy="

:: �������ý���

cd /d "%~dp0"
if NOT "%cd%"=="%cd: =%" (
    echo ��ǰĿ¼��·���к��пո�������š�
    echo �뽫��Ŀ¼�ƶ�����������Ϊ�����ո�����ŵ�Ŀ¼��
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
    echo �˽ű���Ҫ�Թ�����Ȩ��ִ�С�
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

echo ���ڽ�ѹ UUP ת�����򡭡�
if NOT EXIST CustomAppsList.txt "%a7z%" -x!ConvertConfig.ini -y x "%uupConv%" >NUL
if EXIST CustomAppsList.txt "%a7z%" -x!ConvertConfig.ini -x!CustomAppsList.txt -y x "%uupConv%" >NUL
echo.




:DOWNLOAD_APPS
echo ���ڼ���������Ӧ�õ� aria2 �ű�����
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" -o"%aria2Script%" --allow-overwrite=true --auto-file-renaming=false "https://www.uupdump.cn/get.php?id=2d652122-0ea3-477a-9807-c8506fec8fc4&pack=neutral&edition=app&aria2=2"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1

for /F "tokens=2 delims=:" %%i in ('findstr #UUPDUMP_ERROR: "%aria2Script%"') do set DETECTED_ERROR=%%i
if NOT [%DETECTED_ERROR%] == [] (
    echo �޷��� Windows ���·������������ݡ�ԭ��%DETECTED_ERROR%
    echo �����������Ȼ���ڣ��ܿ��������ڳ������صļ��Ѵ� Windows ���·�������ɾ����
    echo.
    pause
    goto :EOF
)

echo ���ڳ�������Ӧ���ļ�����
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" -x16 -s16 -j25 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto :DOWNLOAD_APPS

:DOWNLOAD_UUPS
echo ���ڼ��� aria2 �ű�����
"%aria2%" --no-conf --log-level=info --log="aria2_download.log" -o"%aria2Script%" --allow-overwrite=true --auto-file-renaming=false "https://www.uupdump.cn/get.php?id=2d652122-0ea3-477a-9807-c8506fec8fc4&pack=en-us&edition=professional&aria2=2"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1
echo.

for /F "tokens=2 delims=:" %%i in ('findstr #UUPDUMP_ERROR: "%aria2Script%"') do set DETECTED_ERROR=%%i
if NOT [%DETECTED_ERROR%] == [] (
    echo �޷��� Windows ���·������������ݡ�ԭ��%DETECTED_ERROR%
    echo �����������Ȼ���ڣ��ܿ��������ڳ������صļ��Ѵ� Windows ���·�������ɾ����
    echo.
    pause
    goto :EOF
)

echo ���ڳ��������ļ�����
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
echo �����Ҳ����˽ű�������ļ�֮һ��
pause
goto :EOF

:DOWNLOAD_ERROR
echo.
echo �����������ļ�ʱ��������
pause
goto :EOF

:EOF
