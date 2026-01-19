@echo off
REM Script to make executables standalone and organize build outputs
REM - Executables and DLLs go to build/
REM - Object files go to intermediate/

echo ========================================
echo Making executables standalone...
echo ========================================
echo.

REM Initialize oneAPI environment to find DLLs
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" > nul 2>&1

REM Create directory structure
if not exist "build" mkdir "build"
if not exist "intermediate" mkdir "intermediate"

echo Organizing files...
echo.

REM Move executables to build/
if exist "easywave-sycl.exe" (
    echo Moving easywave-sycl.exe to build/
    move /Y "easywave-sycl.exe" "build\" > nul
)

if exist "easywave-cuda.exe" (
    echo Moving easywave-cuda.exe to build/
    move /Y "easywave-cuda.exe" "build\" > nul
)

REM Move object files from root to intermediate/
echo Moving object files to intermediate/
for %%F in (*.o) do (
    if exist "%%F" move /Y "%%F" "intermediate\" > nul 2>&1
)

REM Move object files from build to intermediate/
for %%F in (build\*.o) do (
    if exist "%%F" move /Y "%%F" "intermediate\" > nul 2>&1
)

echo.
echo Searching for required DLLs...
echo.

REM Find and copy SYCL runtime DLLs to build/
set ONEAPI_ROOT=C:\Program Files (x86)\Intel\oneAPI

REM Common SYCL DLLs needed
set DLL_LIST=sycl8.dll svml_dispmd.dll libmmd.dll libiomp5md.dll ur_win_proxy_loader.dll ur_loader.dll ur_adapter_level_zero.dll ur_adapter_opencl.dll

REM Try to find and copy each DLL
for %%D in (%DLL_LIST%) do (
    echo Looking for %%D...
    
    if exist "build\%%D" (
        echo   [SKIP] Already in build\%%D
    ) else (
        REM Try common locations
        if exist "%ONEAPI_ROOT%\compiler\latest\bin\%%D" (
            echo   [COPY] From compiler\latest\bin
            copy "%ONEAPI_ROOT%\compiler\latest\bin\%%D" "build\" > nul 2>&1
        ) else if exist "%ONEAPI_ROOT%\compiler\2025.1\bin\%%D" (
            echo   [COPY] From compiler\2025.1\bin
            copy "%ONEAPI_ROOT%\compiler\2025.1\bin\%%D" "build\" > nul 2>&1
        ) else if exist "%ONEAPI_ROOT%\compiler\2025.0\bin\%%D" (
            echo   [COPY] From compiler\2025.0\bin
            copy "%ONEAPI_ROOT%\compiler\2025.0\bin\%%D" "build\" > nul 2>&1
        ) else (
            echo   [WARN] Not found: %%D
        )
    )
)

echo.
echo ========================================
echo Creating standalone batch files...
echo ========================================
echo.

REM Create standalone CPU runner
echo Creating run-cpu-standalone.bat...
(
echo @echo off
echo REM Standalone CPU Mode Runner - No environment setup needed!
echo.
echo REM Add build directory to PATH for DLLs
echo set "PATH=%%CD%%\build;%%PATH%%"
echo.
echo echo Creating outputs-cpu directory...
echo if not exist "outputs-cpu" mkdir "outputs-cpu"
echo.
echo echo Deleting previous output files...
echo del /Q outputs-cpu\eWave.* 2^>nul
echo.
echo echo.
echo echo Running simulation in CPU MODE ^(no GPU acceleration^)...
echo echo ========================================
echo echo Start time: %%date%% %%time%%
echo echo ========================================
echo echo.
echo.
echo REM Record start time
echo set START_TIME=%%time%%
echo.
echo REM Get absolute paths
echo set "GRID=%%CD%%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
echo set "SOURCE=%%CD%%\easyWave-master-data\data\faults\BengkuluSept2007.flt"
echo.
echo cd outputs-cpu
echo ..\build\easywave-sycl.exe -verbose -grid "%%GRID%%" -source "%%SOURCE%%" -time 1440 -step 1 -progress 1
echo cd ..
echo.
echo echo.
echo echo ========================================
echo echo Simulation complete!
echo echo End time: %%date%% %%time%%
echo echo ========================================
echo echo.
echo.
echo REM Calculate elapsed time
echo set END_TIME=%%time%%
echo echo Start: %%START_TIME%%
echo echo End:   %%END_TIME%%
echo.
echo powershell -Command "$start = [datetime]::ParseExact^('%%START_TIME%%', 'HH:mm:ss.ff', $null^); $end = [datetime]::ParseExact^('%%END_TIME%%', 'HH:mm:ss.ff', $null^); $elapsed = $end - $start; if ^($elapsed.TotalSeconds -lt 0^) { $elapsed = $elapsed.Add^([TimeSpan]::FromDays^(1^)^) }; Write-Host ^('Execution time: {0:D2}h {1:D2}m {2:D2}s' -f [int]$elapsed.TotalHours, $elapsed.Minutes, $elapsed.Seconds^)"
echo.
echo if exist "outputs-cpu\eWave.2D.sshmax" ^(
echo     echo SUCCESS! Main output file created: eWave.2D.sshmax
echo ^) else ^(
echo     echo WARNING: Main output file missing
echo ^)
) > run-cpu-standalone.bat

echo Created: run-cpu-standalone.bat
echo.

REM Create standalone GPU runner if CUDA exe exists
if exist "build\easywave-cuda.exe" (
    echo Creating run-gpu-standalone.bat...
    (
    echo @echo off
    echo REM Standalone GPU Mode Runner - No environment setup needed!
    echo.
    echo REM Add build directory to PATH for DLLs
    echo set "PATH=%%CD%%\build;%%PATH%%"
    echo.
    echo echo Creating outputs-gpu directory...
    echo if not exist "outputs-gpu" mkdir "outputs-gpu"
    echo.
    echo echo Deleting previous output files...
    echo del /Q outputs-gpu\eWave.* 2^>nul
    echo.
    echo echo.
    echo echo Running simulation in GPU MODE ^(CUDA acceleration^)...
    echo echo ========================================
    echo echo Start time: %%date%% %%time%%
    echo echo ========================================
    echo echo.
    echo.
    echo REM Record start time
    echo set START_TIME=%%time%%
    echo.
    echo REM Get absolute paths
    echo set "GRID=%%CD%%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
    echo set "SOURCE=%%CD%%\easyWave-master-data\data\faults\BengkuluSept2007.flt"
    echo.
    echo cd outputs-gpu
    echo ..\build\easywave-cuda.exe -gpu -verbose -grid "%%GRID%%" -source "%%SOURCE%%" -time 1440 -step 1 -progress 1
    echo cd ..
    echo.
    echo echo.
    echo echo ========================================
    echo echo Simulation complete!
    echo echo End time: %%date%% %%time%%
    echo echo ========================================
    echo echo.
    echo.
    echo REM Calculate elapsed time
    echo set END_TIME=%%time%%
    echo echo Start: %%START_TIME%%
    echo echo End:   %%END_TIME%%
    echo.
    echo powershell -Command "$start = [datetime]::ParseExact^('%%START_TIME%%', 'HH:mm:ss.ff', $null^); $end = [datetime]::ParseExact^('%%END_TIME%%', 'HH:mm:ss.ff', $null^); $elapsed = $end - $start; if ^($elapsed.TotalSeconds -lt 0^) { $elapsed = $elapsed.Add^([TimeSpan]::FromDays^(1^)^) }; Write-Host ^('Execution time: {0:D2}h {1:D2}m {2:D2}s' -f [int]$elapsed.TotalHours, $elapsed.Minutes, $elapsed.Seconds^)"
    echo.
    echo if exist "outputs-gpu\eWave.2D.sshmax" ^(
    echo     echo SUCCESS! Main output file created: eWave.2D.sshmax
    echo ^) else ^(
    echo     echo WARNING: Main output file missing
    echo ^)
    ) > run-gpu-standalone.bat
    
    echo Created: run-gpu-standalone.bat
    echo.
)

echo ========================================
echo Setup complete!
echo ========================================
echo.
echo Directory structure:
echo   build\          - Executables and DLLs
echo   intermediate\   - Object files (.o)
echo.
echo New standalone batch files:
echo   - run-cpu-standalone.bat  (no environment setup needed)
if exist "run-gpu-standalone.bat" echo   - run-gpu-standalone.bat  (no environment setup needed)
echo.
echo You can now run simulations without calling setvars.bat!
