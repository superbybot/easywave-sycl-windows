@echo off
echo ==========================================
echo Building easyWave SYCL (No Make)
echo ==========================================

REM Set up Visual Studio environment
set "VS_PATH="
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
)

if "%VS_PATH%"=="" (
    echo ERROR: Could not find vcvars64.bat!
    exit /b 1
)

call "%VS_PATH%"

REM Set up Intel oneAPI environment
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" --force

echo.
echo Compiling...
icpx -fsycl -O3 -DUSE_LOOP_EXTEND EasyWave.cpp ewGpuNode.sycl.cpp cOgrd.cpp cOkadaEarthquake.cpp cOkadaFault.cpp cSphere.cpp ewGrid.cpp ewOut2D.cpp ewParam.cpp ewPOIs.cpp ewSource.cpp ewStep.cpp okada.cpp utilits.cpp ewKernels.sycl.cpp -o easywave-sycl.exe

if errorlevel 1 (
    echo.
    echo Build failed!
    exit /b 1
)

echo.
echo Build successful!
echo Executable: easywave-sycl.exe
