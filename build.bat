@echo off
REM Build script for easyWave SYCL on Windows
REM Uses Visual Studio 2022 Build Tools + Intel oneAPI

echo ==========================================
echo Building easyWave SYCL
echo ==========================================
echo.

REM Initialize Visual Studio Build Tools environment FIRST
echo Setting up Visual Studio 2022 Build Tools environment...
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 (
    echo ERROR: Failed to initialize Visual Studio environment
    exit /b 1
)

REM Initialize Intel oneAPI environment
echo.
echo Setting up Intel oneAPI environment...
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" --force
if errorlevel 1 (
    echo WARNING: setvars.bat returned an error, but continuing...
)

echo.
echo Checking compiler...
where icpx
if errorlevel 1 (
    echo ERROR: icpx compiler not found!
    exit /b 1
)

echo.
echo Compiler version:
icpx --version
echo.

REM Navigate to project directory
cd /d "%~dp0"

REM Check if make.inc exists
if not exist "make.inc" (
    echo Creating make.inc from make.inc.oneapi...
    copy make.inc.oneapi make.inc
)

REM Clean previous build
echo Cleaning previous build...
del /Q *.o 2>nul
if exist "build" rmdir /S /Q "build"

REM Create build directory for object files
if not exist "build" mkdir "build"

echo.
echo Building easyWave SYCL...
C:\msys64\usr\bin\make.exe

if errorlevel 1 (
    echo.
    echo ==========================================
    echo Build failed!
    echo ==========================================
    echo.
    echo Check the error messages above.
    exit /b 1
)

REM Move executable to builds folder
if exist "easywave-sycl" move /Y "easywave-sycl" "easywave-sycl.exe" >nul

echo.
echo ==========================================
echo Build successful!
echo ==========================================
echo.
if exist "easywave-sycl.exe" (
    echo Executable: easywave-sycl.exe
    echo Size: 
    dir easywave-sycl.exe | find "easywave-sycl.exe"
)
echo.
echo To run:
echo   .\run.bat -gpu -verbose
echo.
