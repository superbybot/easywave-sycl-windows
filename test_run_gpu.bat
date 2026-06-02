@echo off
REM Standalone GPU Mode Runner - No environment setup needed!

REM Add build directory to PATH for DLLs
set "PATH=%CD%\build;%PATH%"

echo Creating outputs-gpu directory...
if not exist "outputs-gpu" mkdir "outputs-gpu"

echo Deleting previous output files...
del /Q outputs-gpu\eWave.* 2>nul

echo.
echo Running simulation in GPU MODE (CUDA acceleration)...
echo ========================================
echo Start time: %date% %time%
echo ========================================
echo.

REM Record start time
set START_TIME=%time%

REM Get absolute paths
REM set "GRID=%CD%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
REM set "SOURCE=%CD%\easyWave-master-data\data\faults\BengkuluSept2007.flt"

REM set "GRID=%CD%\easyWave-master-data\data\grids\Philippines_2m_Bathy.grd"
set "GRID=%CD%\easyWave-master-data\data\grids\GEBCO_Nothern_Phil_15s.grd"

set "SOURCE=%CD%\easyWave-master-data\data\faults\Phil_Trench_06.flt"
set "POI=%CD%\easyWave-master-data\data\pois\Aurora.poi"

REM cd outputs-gpu
REM ..\build\easywave-cuda.exe -gpu -verbose -grid "%GRID%" -source "%SOURCE%" -time 1440 -step 1 -progress 1
REM cd ..

cd outputs-gpu
..\build\easywave-cuda.exe -gpu -verbose -grid "%GRID%" -source "%SOURCE%" -poi %poi% -time 480 -step 1 -progress 1
cd ..


echo.
echo ========================================
echo Simulation complete!
echo End time: %date% %time%
echo ========================================
echo.

REM Calculate elapsed time
set END_TIME=%time%
echo Start: %START_TIME%
echo End:   %END_TIME%

REM powershell -Command "$start = [datetime]::ParseExact^('%START_TIME%', 'HH:mm:ss.ff', $null^); $end = [datetime]::ParseExact^('%END_TIME%', 'HH:mm:ss.ff', $null^); $elapsed = $end - $start; if ^($elapsed.TotalSeconds -lt 0^) { $elapsed = $elapsed.Add^([TimeSpan]::FromDays^(1^)^) }; Write-Host ^('Execution time: {0:D2}h {1:D2}m {2:D2}s' -f [int]$elapsed.TotalHours, $elapsed.Minutes, $elapsed.Seconds^)"

if exist "outputs-gpu\eWave.2D.sshmax" (
    echo SUCCESS! Main output file created: eWave.2D.sshmax
) else (
    echo WARNING: Main output file missing
)

PAUSE
