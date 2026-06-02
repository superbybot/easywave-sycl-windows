@echo off
REM Build script for EasyWave CUDA version

REM Set up Visual Studio environment
echo Setting up Visual Studio environment...
set "VS_PATH="
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat"
)

if "%VS_PATH%"=="" (
    echo ERROR: Could not find vcvarsall.bat!
    exit /b 1
)

call "%VS_PATH%" x64
echo.

set CUDA_DIR=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9
if not exist "%CUDA_DIR%" (
    echo CUDA v12.9 not found at "%CUDA_DIR%", falling back to v13.1...
    set CUDA_DIR=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.1
)

echo Using CUDA Toolkit at: "%CUDA_DIR%"
set NVCC="%CUDA_DIR%\bin\nvcc.exe"
set NVCC_FLAGS=-allow-unsupported-compiler -gencode arch=compute_61,code=sm_61 -gencode arch=compute_61,code=compute_61 -O3 -std=c++17 --extra-device-vectorization --use_fast_math -c
set CXX_FLAGS=/nologo /O2 /EHsc /std:c++17 /D_CRT_SECURE_NO_WARNINGS /DEW_FORCE_CUDA /I"%CUDA_DIR%\include" /c

echo Cleaning old build artifacts...
del /Q *.o 2>nul
del /Q *.obj 2>nul
del /Q easywave-cuda.exe 2>nul
echo.

echo Building EasyWave CUDA version...
echo.

REM Compile CUDA source files
echo Compiling ewKernels.cuda.cu...
%NVCC% %NVCC_FLAGS% ewKernels.cuda.cu -o ewKernels.cuda.obj

REM Compile C++ source files with host compiler
echo Compiling EasyWave.cpp...
cl %CXX_FLAGS% EasyWave.cpp /FoEasyWave.obj

echo Compiling ewGpuNode.cpp...
cl %CXX_FLAGS% ewGpuNode.cpp /FoewGpuNode.obj

echo Compiling cOgrd.cpp...
cl %CXX_FLAGS% cOgrd.cpp /FocOgrd.obj

echo Compiling cOkadaEarthquake.cpp...
cl %CXX_FLAGS% cOkadaEarthquake.cpp /FocOkadaEarthquake.obj

echo Compiling cOkadaFault.cpp...
cl %CXX_FLAGS% cOkadaFault.cpp /FocOkadaFault.obj

echo Compiling cSphere.cpp...
cl %CXX_FLAGS% cSphere.cpp /FocSphere.obj

echo Compiling ewGrid.cpp...
cl %CXX_FLAGS% ewGrid.cpp /FoewGrid.obj

echo Compiling ewOut2D.cpp...
cl %CXX_FLAGS% ewOut2D.cpp /FoewOut2D.obj

echo Compiling ewParam.cpp...
cl %CXX_FLAGS% ewParam.cpp /FoewParam.obj

echo Compiling ewPOIs.cpp...
cl %CXX_FLAGS% ewPOIs.cpp /FoewPOIs.obj

echo Compiling ewSource.cpp...
cl %CXX_FLAGS% ewSource.cpp /FoewSource.obj

echo Compiling ewStep.cpp...
cl %CXX_FLAGS% ewStep.cpp /FoewStep.obj

echo Compiling okada.cpp...
cl %CXX_FLAGS% okada.cpp /Fookada.obj

echo Compiling utilits.cpp...
cl %CXX_FLAGS% utilits.cpp /Foutilits.obj

echo.
echo Linking...
%NVCC% -allow-unsupported-compiler EasyWave.obj ewKernels.cuda.obj ewGpuNode.obj cOgrd.obj cOkadaEarthquake.obj cOkadaFault.obj cSphere.obj ewGrid.obj ewOut2D.obj ewParam.obj ewPOIs.obj ewSource.obj ewStep.obj okada.obj utilits.obj -o easywave-cuda.exe

if exist easywave-cuda.exe (
    echo.
    echo ========================================
    echo Build successful!
    echo Created: easywave-cuda.exe
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Build failed!
    echo ========================================
    exit /b 1
)
