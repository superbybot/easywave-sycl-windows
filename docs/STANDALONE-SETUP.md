# Standalone Executable Setup

## ✅ Setup Complete!

Your easyWave executables are now **standalone** and organized:

### Directory Structure

```
easywave-sycl-windows/
├── build/                          ← Executables + DLLs (standalone)
│   ├── easywave-sycl.exe          (SYCL version)
│   ├── easywave-cuda.exe          (CUDA version)
│   ├── cudart64_13.dll            (CUDA runtime - for CUDA exe)
│   ├── sycl8.dll                  (SYCL runtime - for SYCL exe)
│   ├── svml_dispmd.dll            (Math library)
│   ├── libmmd.dll                 (Math library)
│   └── libiomp5md.dll             (OpenMP runtime)
│
├── intermediate/                   ← Object files (.o)
│   └── *.o files                  (Build artifacts)
│
├── run-cpu-standalone.bat         ← Run CPU mode (no setup needed!)
└── run-gpu-standalone.bat         ← Run GPU mode (no setup needed!)
```

---

## How It Works

### Before (Required Environment Setup)
```batch
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"
easywave-sycl.exe ...
```

### After (Standalone)
```batch
run-cpu-standalone.bat
```

The standalone batch files automatically:
1. Add `build\` to PATH so DLLs are found
2. Run the executable from the `build\` folder
3. No need to call `setvars.bat`!

---

## Usage

### CPU Mode (Recommended)
```cmd
.\run-cpu-standalone.bat
```

### GPU Mode (CUDA)
```cmd
.\run-gpu-standalone.bat
```

Both scripts:
- ✅ Work without environment setup
- ✅ Create output directories automatically
- ✅ Show execution time
- ✅ Verify output files were created

---

## What Was Done

1. **Copied Required DLLs** to `build/` folder:
   
   **For SYCL executable:**
   - `sycl8.dll` - SYCL runtime library
   - `ur_adapter_level_zero.dll` - Level Zero adapter
   - `ur_adapter_opencl.dll` - OpenCL adapter
   - `ur_loader.dll` - Unified Runtime loader
   - `ur_win_proxy_loader.dll` - Windows proxy loader
   - `svml_dispmd.dll` - Short Vector Math Library
   - `libmmd.dll` - Math library
   - `libiomp5md.dll` - OpenMP runtime
   
   **For CUDA executable:**
   - `cudart64_13.dll` - CUDA Runtime Library

2. **Moved Executables** to `build/`:
   - `easywave-sycl.exe`
   - `easywave-cuda.exe`

3. **Organized Object Files** to `intermediate/`:
   - All `.o` files moved out of root directory
   - Keeps project clean and organized

4. **Created Standalone Batch Files**:
   - `run-cpu-standalone.bat` - No environment setup needed
   - `run-gpu-standalone.bat` - No environment setup needed

---

## Benefits

✅ **No Environment Setup** - Just run the batch file  
✅ **Portable** - Copy the `build/` folder to another machine  
✅ **Clean Project** - Object files in `intermediate/`, executables in `build/`  
✅ **Easy Distribution** - Share `build/` folder with colleagues  

---

## Technical Details

The standalone batch files work by:
1. Adding `build\` directory to PATH: `set "PATH=%CD%\build;%PATH%"`
2. This allows Windows to find the DLLs when running the executable
3. No need for Intel oneAPI environment variables

### DLL Dependencies

#### SYCL Executable (`easywave-sycl.exe`)
The SYCL executable requires these Intel oneAPI DLLs:
- **sycl8.dll** (3.7 MB) - Core SYCL runtime
- **ur_adapter_level_zero.dll** (1.1 MB) - Level Zero adapter
- **ur_adapter_opencl.dll** (0.3 MB) - OpenCL adapter
- **ur_loader.dll** (1.3 MB) - Unified Runtime loader
- **ur_win_proxy_loader.dll** (0.1 MB) - Windows proxy loader
- **svml_dispmd.dll** (18 MB) - Vectorized math functions
- **libmmd.dll** (4.0 MB) - Math dispatch library
- **libiomp5md.dll** (1.5 MB) - OpenMP parallel runtime

Total DLL size: ~30 MB

#### CUDA Executable (`easywave-cuda.exe`)
The CUDA executable requires:
- **cudart64_13.dll** (0.5 MB) - CUDA Runtime Library (version 13.1)

**Note**: The target device must have NVIDIA GPU drivers installed, but does NOT need the full CUDA Toolkit. The `cudart64_13.dll` is the only redistributable runtime DLL needed.

Total DLL size: ~0.5 MB

---

## Rebuilding

If you rebuild the project, run `make-standalone.bat` again to:
- Move new executables to `build/`
- Move new object files to `intermediate/`
- Update standalone batch files

```cmd
.\make-standalone.bat
```

---

## Distribution

To share your standalone build:

1. **Zip the build folder**:
   ```cmd
   tar -a -c -f easywave-standalone.zip build
   ```

2. **Share with others** - They can run without Intel oneAPI installed!

3. **Include data** (optional):
   ```cmd
   tar -a -c -f easywave-complete.zip build easyWave-master-data run-cpu-standalone.bat
   ```

---

## Notes

- The original `run-cpu.bat` and `run-gpu.bat` still work (they call `setvars.bat`)
- Use the `-standalone` versions for convenience
- The `build/` folder is now self-contained with all dependencies
