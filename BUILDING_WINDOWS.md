# Building easyWave SYCL on Windows

This guide explains how to compile the easyWave SYCL tsunami simulation software on Windows.

## Compatibility Summary

✅ **YES - This code will compile on Windows** with proper setup.

The code is highly portable with no POSIX-specific dependencies, using only standard C/C++ libraries.

## Prerequisites

### Required Software

1. **Intel oneAPI Base Toolkit** (Windows version)
   - Download: https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit.html
   - Includes the `icpx` (Intel DPC++ Compiler) needed for SYCL
   - Supports Windows 10/11

2. **Build Tools** (choose one option):
   - **Option A: MinGW-w64 + MSYS2** (easiest for using existing Makefile)
   - **Option B: CMake** (recommended for cross-platform builds)
   - **Option C: Visual Studio** with Intel oneAPI integration

3. **Git for Windows** (optional, for version control)

## Build Methods

### Method 1: Using MSYS2 + MinGW (Recommended)

This method uses the existing Makefile with minimal changes.

#### Setup

1. **Install MSYS2**
   - Download from: https://www.msys2.org/
   - Run the installer and follow instructions

2. **Install build tools in MSYS2**
   ```bash
   # Open MSYS2 terminal
   pacman -S make
   ```

3. **Install Intel oneAPI**
   - Download and install Intel oneAPI Base Toolkit
   - Note the installation path (typically `C:\Program Files (x86)\Intel\oneAPI`)

#### Compilation

1. **Open MSYS2 terminal**

2. **Source Intel oneAPI environment**
   ```bash
   source "/c/Program Files (x86)/Intel/oneAPI/setvars.sh"
   ```

3. **Navigate to project directory**
   ```bash
   cd /path/to/easywave-sycl-windows
   ```

4. **Set up build configuration**
   ```bash
   cp make.inc.oneapi make.inc
   ```

5. **Build**
   ```bash
   make
   ```

6. **Run**
   ```bash
   ./easywave-sycl -gpu -verbose
   ```

### Method 2: Using CMake (Cross-Platform)

This method creates a more portable build system.

#### Setup

1. **Install CMake**
   - Download from: https://cmake.org/download/
   - Or use `winget install Kitware.CMake`

2. **Install Intel oneAPI** (as above)

3. **Create `CMakeLists.txt`** in project root:
   ```cmake
   cmake_minimum_required(VERSION 3.20)
   project(easywave-sycl CXX)

   set(CMAKE_CXX_COMPILER icpx)
   set(CMAKE_CXX_STANDARD 17)

   add_compile_options(-fsycl -O3)

   set(BASE_SOURCES
       EasyWave.cpp
       ewGpuNode.sycl.cpp
       cOgrd.cpp
       cOkadaEarthquake.cpp
       cOkadaFault.cpp
       cSphere.cpp
       ewGrid.cpp
       ewOut2D.cpp
       ewParam.cpp
       ewPOIs.cpp
       ewSource.cpp
       ewStep.cpp
       okada.cpp
       utilits.cpp
       ewKernels.sycl.cpp
   )

   add_executable(easywave-sycl ${BASE_SOURCES})
   target_link_options(easywave-sycl PRIVATE -fsycl)
   ```

#### Compilation

1. **Open Command Prompt or PowerShell**

2. **Source Intel oneAPI environment**
   ```cmd
   "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"
   ```

3. **Create build directory**
   ```cmd
   mkdir build
   cd build
   ```

4. **Configure and build**
   ```cmd
   cmake .. -G "NMake Makefiles"
   nmake
   ```

### Method 3: Visual Studio

1. **Install Visual Studio** (2019 or later)
2. **Install Intel oneAPI** with Visual Studio integration
3. **Create new project** and add all `.cpp` files
4. **Configure project properties**:
   - C/C++ → Command Line → Add: `-fsycl`
   - Linker → Command Line → Add: `-fsycl`
5. **Build** using Visual Studio

## Potential Issues & Solutions

### Issue: Compiler flags not supported

**Problem**: Some flags in `make.inc.oneapi` may not work on Windows

**Solution**: Edit `make.inc` and simplify flags:
```makefile
CXX=icpx
CXXFLAGS=-fsycl -O3
```

### Issue: Path separators

**Problem**: Windows uses backslashes, code uses forward slashes

**Solution**: Modern compilers accept forward slashes - should work as-is

### Issue: SYCL device not found

**Problem**: No compatible GPU detected

**Solution**: SYCL will automatically fall back to CPU execution

## Running easyWave

After successful compilation, you'll have `easywave-sycl.exe`.

### Basic Usage

```cmd
easywave-sycl.exe -gpu -verbose -grid "path\to\grid.grd" -source "path\to\fault.grd"
```

### Example with Test Data

Download test data from the GFZ repository, then:

```cmd
easywave-sycl.exe -gpu -verbose -propagate 1500 -step 5 ^
  -grid "data\grids\e2r4Pacific.grd" ^
  -source "data\faults\uz.Tohoku11.grd" ^
  -time 1440
```

## Verification

### Check compilation
```cmd
easywave-sycl.exe --help
```

### Verify SYCL device
The program will print detected SYCL devices when run with `-verbose`.

## Performance Notes

- **GPU Acceleration**: Requires Intel GPU or compatible SYCL device
- **CPU Fallback**: Works on any CPU if no GPU available
- **Optimization**: Use `-O3` flag for best performance

## Troubleshooting

### Linker errors
- Ensure Intel oneAPI environment is sourced
- Check that all `.cpp` files are included in build

### Runtime errors
- Verify Intel oneAPI runtime libraries are in PATH
- Check input data file paths are correct

## Additional Resources

- Intel oneAPI Documentation: https://www.intel.com/content/www/us/en/docs/oneapi/
- SYCL Specification: https://www.khronos.org/sycl/
- Original easyWave: https://git.gfz-potsdam.de/id2/geoperil/easyWave

## Support

For issues specific to this SYCL port, refer to the main README.md.
For Intel oneAPI issues, consult Intel's support forums.
