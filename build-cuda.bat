@echo off
REM Build script for EasyWave CUDA version

REM Set up Visual Studio environment
echo Setting up Visual Studio environment...
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
echo.

set NVCC="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.1\bin\nvcc.exe"
set CXXFLAGS=-O3 -std=c++17 --extra-device-vectorization --use_fast_math -x cu

echo Building EasyWave CUDA version...
echo.

REM Compile all source files
echo Compiling EasyWave.cpp...
%NVCC% %CXXFLAGS% -c EasyWave.cpp -o EasyWave.o

echo Compiling ewKernels.cuda.cu...
%NVCC% %CXXFLAGS% -c ewKernels.cuda.cu -o ewKernels.cuda.o

echo Compiling ewGpuNode.cuda.cu...
%NVCC% %CXXFLAGS% -c ewGpuNode.cuda.cu -o ewGpuNode.cuda.o

echo Compiling cOgrd.cpp...
%NVCC% %CXXFLAGS% -c cOgrd.cpp -o cOgrd.o

echo Compiling cOkadaEarthquake.cpp...
%NVCC% %CXXFLAGS% -c cOkadaEarthquake.cpp -o cOkadaEarthquake.o

echo Compiling cOkadaFault.cpp...
%NVCC% %CXXFLAGS% -c cOkadaFault.cpp -o cOkadaFault.o

echo Compiling cSphere.cpp...
%NVCC% %CXXFLAGS% -c cSphere.cpp -o cSphere.o

echo Compiling ewGrid.cpp...
%NVCC% %CXXFLAGS% -c ewGrid.cpp -o ewGrid.o

echo Compiling ewOut2D.cpp...
%NVCC% %CXXFLAGS% -c ewOut2D.cpp -o ewOut2D.o

echo Compiling ewParam.cpp...
%NVCC% %CXXFLAGS% -c ewParam.cpp -o ewParam.o

echo Compiling ewPOIs.cpp...
%NVCC% %CXXFLAGS% -c ewPOIs.cpp -o ewPOIs.o

echo Compiling ewSource.cpp...
%NVCC% %CXXFLAGS% -c ewSource.cpp -o ewSource.o

echo Compiling ewStep.cpp...
%NVCC% %CXXFLAGS% -c ewStep.cpp -o ewStep.o

echo Compiling okada.cpp...
%NVCC% %CXXFLAGS% -c okada.cpp -o okada.o

echo Compiling utilits.cpp...
%NVCC% %CXXFLAGS% -c utilits.cpp -o utilits.o

echo.
echo Linking...
%NVCC% EasyWave.o ewKernels.cuda.o ewGpuNode.cuda.o cOgrd.o cOkadaEarthquake.o cOkadaFault.o cSphere.o ewGrid.o ewOut2D.o ewParam.o ewPOIs.o ewSource.o ewStep.o okada.o utilits.o -o easywave-cuda.exe

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
