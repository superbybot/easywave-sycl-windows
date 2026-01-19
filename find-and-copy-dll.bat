@echo off
REM Script to find and copy missing ur_win_loading_proxy.dll

echo Searching for ur_win_loading_proxy.dll...
echo This may take a minute...
echo.

REM Initialize oneAPI environment to get the DLL in PATH
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1

REM Try to find the DLL using where command
where ur_win_loading_proxy.dll >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Found DLL in PATH!
    for /f "delims=" %%i in ('where ur_win_loading_proxy.dll') do (
        echo Source: %%i
        echo Copying to build directory...
        copy "%%i" "build\" >nul
        if exist "build\ur_win_loading_proxy.dll" (
            echo SUCCESS! DLL copied to build\
            goto :end
        )
    )
) else (
    echo DLL not found in PATH after loading oneAPI environment.
    echo.
    echo Please manually copy ur_win_loading_proxy.dll to the build\ directory.
    echo You can find it by searching your Intel oneAPI installation.
)

:end
echo.
pause
