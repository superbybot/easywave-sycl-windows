# easyWave SYCL - Setup Guide

## Prerequisites

Before starting, ensure you have:
- ✅ **MSYS2** installed at `C:\msys64`
- ✅ **Intel oneAPI Base Toolkit 2025.3.0** installed
- ✅ **Visual Studio Build Tools 2022** with C++ workload

---

## 1. Build the Project

```cmd
cd C:\Users\Wonderfy149\Documents\easywave-sycl-windows
build.bat
```

**Expected output:**
```
==========================================
Build successful!
==========================================
Executable: easywave-sycl.exe
```

---

## 2. Download Test Data

The test data is **not included** in this repository (see `.gitignore`). You need to download it separately.

### Option A: Download Archive (Recommended)

```cmd
cd C:\Users\Wonderfy149\Documents\easywave-sycl-windows

REM Download the entire easyWave repository
curl -L "https://git.gfz-potsdam.de/id2/geoperil/easyWave/-/archive/master/easyWave-master.zip" -o easyWave-master.zip

REM Extract the archive
tar -xf easyWave-master.zip

REM Clean up zip file
del easyWave-master.zip
```

**Result:** You'll have `easyWave-master\` folder with all test data in `easyWave-master\data\`.

### Option B: Use Git Clone

```cmd
cd C:\Users\Wonderfy149\Documents\easywave-sycl-windows

REM Clone the repository (rename to easyWave-master-data)
git clone https://git.gfz-potsdam.de/id2/geoperil/easyWave.git easyWave-master-data
```

### Option C: Manual Download

1. Visit: https://git.gfz-potsdam.de/id2/geoperil/easyWave/-/tree/master/data
2. Click "Download" → "Download zip"
3. Extract to `easywave-sycl-windows\easyWave-master-data\`

---

## 3. Verify Setup

Check that you have the required files:

```cmd
dir easyWave-master-data\data\grids
dir easyWave-master-data\data\faults
```

**You should see:**
- `easyWave-master-data\data\grids\e2Asean.grd`
- `easyWave-master-data\data\grids\e2Indian.grd`
- `easyWave-master-data\data\faults\fault.inp`
- `easyWave-master-data\data\faults\BengkuluSept2007.flt`

---

## 4. Quick Test

Run a test simulation using CPU mode (recommended):

```cmd
.\run-cpu.bat
```

**Expected output:**
```
Loading bathymetry from easyWave-master-data\data\grids\e2Asean.grd
Stable CFL time step: 8.34961 sec
Read source from easyWave-master-data\data\faults\fault.inp
...
Runtime: X.XXX s, final domain: ...
```

**Output files created in `outputs-cpu/`:**
- `eWave.2D.sshmax` - Maximum wave height
- `eWave.2D.time` - Arrival times
- `eWave.2D.idx` - Index file

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `sycl8.dll not found` | Use `run-cpu.bat` instead of direct execution |
| `Cannot open grid file` | Check that `easyWave-master-data\` folder exists |
| Build fails | See `docs/BUILD_PROCESS.md` |
| Data folder missing | Re-run download steps in section 2 |

---

## Next Steps

- See `docs/2-RUNNING.md` for detailed usage instructions
- See `docs/3-OUTPUT.md` for output file formats
- Use `run-cpu.bat` for reliable CPU-based simulations

---

## Notes

- **GPU mode is not recommended** - The current SYCL executable has issues with GPU execution
- **CPU mode works reliably** - Use `run-cpu.bat` for all simulations
- **Test data is large** (~500 MB) - It's excluded from git via `.gitignore`
