@echo off
REM EasyWave CPU vs GPU Consistency Test Case Runner

echo ============================================================
echo         EasyWave Consistency Test Case Auto-Runner
echo ============================================================
echo.

REM 1. Check for executables
if not exist "build\easywave-cuda.exe" (
    echo [WARNING] build\easywave-cuda.exe not found!
    echo Attempting to build using build-cuda.bat...
    echo.
    call build-cuda.bat
    if errorlevel 1 (
        echo [ERROR] Failed to automatically build easywave-cuda.exe!
        echo Please ensure you compile the binary first.
        echo.
        pause
        exit /b 1
    )
    call make-standalone.bat
    echo.
)
if not exist "build\easywave-sycl.exe" (
    echo [WARNING] build\easywave-sycl.exe not found!
    echo Attempting to build using build-sycl-no-make.bat...
    echo.
    call build-sycl-no-make.bat
    if errorlevel 1 (
        echo [ERROR] Failed to automatically build easywave-sycl.exe!
        echo Please ensure you compile the binary first.
        echo.
        pause
        exit /b 1
    )
    call make-standalone.bat
    echo.
)

REM 2. Check for Python
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found in your PATH!
    echo Please install Python 3 and add it to your PATH to run this test.
    echo.
    pause
    exit /b 1
)

REM 3. Run the python consistency validation suite
echo [INFO] Dependencies verified. Running CPU vs GPU simulation...
echo.
python test_cpu_gpu_consistency.py --grid "easyWave-master-data\data\grids\e2r4Asean.grd" --source "easyWave-master-data\data\faults\fault.inp" --time 10 --cpu-exe "build\easywave-sycl.exe" --gpu-exe "build\easywave-cuda.exe" --tolerance 1e-4

if errorlevel 1 (
    echo.
    echo [FAIL] Consistency test did not pass or returned an error.
    echo.
) else (
    echo.
    echo [PASS] Consistency test completed successfully!
    echo.
)

pause
