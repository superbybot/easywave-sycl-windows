# Building easyWave SYCL on macOS

This guide explains how to compile the easyWave SYCL tsunami simulation software on macOS.

## Compatibility Summary

✅ **YES - This code compiles excellently on macOS!**

macOS is actually the **easiest platform** for building this code due to its native Unix environment.

## System Requirements

### Check Your Mac Type

```bash
uname -m
```

- **x86_64**: Intel Mac - Full Intel oneAPI support
- **arm64**: Apple Silicon (M1/M2/M3) - Use hipSYCL/AdaptiveCpp for best results

## Prerequisites

### For All Macs

1. **Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

2. **Homebrew** (recommended for package management)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Compiler Options

Choose based on your Mac type:

#### Option A: Intel oneAPI (Best for Intel Macs)

**Compatibility:**
- ✅ Intel Macs: Excellent
- ⚠️ Apple Silicon: Works via Rosetta 2 (slower, CPU-only)

**Installation:**
1. Download Intel oneAPI Base Toolkit from:
   https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit.html

2. Run the installer and follow instructions

3. Source the environment:
   ```bash
   source /opt/intel/oneapi/setvars.sh
   ```

#### Option B: hipSYCL/AdaptiveCpp (Best for Apple Silicon)

**Compatibility:**
- ✅ Apple Silicon: Excellent (native ARM, can use Metal GPU)
- ✅ Intel Macs: Good

**Installation:**

Try Homebrew first:
```bash
brew install adaptivecpp
# or
brew install hipsycl
```

If not available via Homebrew, install from source:
```bash
git clone https://github.com/AdaptiveCpp/AdaptiveCpp
cd AdaptiveCpp
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make -j$(sysctl -n hw.ncpu)
sudo make install
```

## Building with Intel oneAPI

### Quick Start (Intel Macs)

```bash
# Navigate to project
cd /path/to/easywave-sycl-windows

# Source Intel oneAPI environment
source /opt/intel/oneapi/setvars.sh

# Set up build configuration
cp make.inc.oneapi make.inc

# Build
make

# Run
./easywave-sycl -gpu -verbose
```

### Detailed Steps

1. **Source Intel oneAPI environment** (do this in each new terminal):
   ```bash
   source /opt/intel/oneapi/setvars.sh
   ```

2. **Configure build**:
   ```bash
   cp make.inc.oneapi make.inc
   ```

3. **Optional: Adjust compiler flags** (if needed):
   ```bash
   # Edit make.inc if you encounter issues with -march=native
   nano make.inc
   ```

4. **Compile**:
   ```bash
   make clean
   make
   ```

5. **Verify**:
   ```bash
   ./easywave-sycl --help
   ```

## Building with hipSYCL/AdaptiveCpp

### For Apple Silicon Macs (Recommended)

1. **Configure build**:
   ```bash
   cp make.inc.hipsycl.amd make.inc
   ```

2. **Edit `make.inc`** for macOS:
   ```makefile
   CXX=acpp
   CXXFLAGS=-O3 --acpp-targets=omp
   # For Metal GPU support (if available):
   # CXXFLAGS=-O3 --acpp-targets=metal
   ```

3. **Build**:
   ```bash
   make clean
   make
   ```

### For Intel Macs with hipSYCL

```bash
cp make.inc.hipsycl.amd make.inc
# Edit make.inc to use CPU target
make
```

## Running easyWave

### Basic Usage

```bash
./easywave-sycl -gpu -verbose
```

### Example with Test Data

First, download test data from the GFZ repository:
```bash
git clone https://git.gfz-potsdam.de/id2/geoperil/easyWave.git gfz-easywave
```

Then run:
```bash
./easywave-sycl -gpu -verbose \
  -propagate 1500 \
  -step 5 \
  -grid "gfz-easywave/data/grids/e2r4Pacific.grd" \
  -source "gfz-easywave/data/faults/uz.Tohoku11.grd" \
  -time 1440
```

## Troubleshooting

### Issue: `icpx: command not found`

**Solution**: Source Intel oneAPI environment:
```bash
source /opt/intel/oneapi/setvars.sh
```

Add to your `~/.zshrc` or `~/.bash_profile` for automatic loading:
```bash
echo 'source /opt/intel/oneapi/setvars.sh' >> ~/.zshrc
```

### Issue: Compiler flags error with `-march=native`

**Solution**: Edit `make.inc` and remove problematic flags:
```makefile
# Change from:
CXXFLAGS=-fsycl -O3 -g -march=native -mtune=native ...

# To:
CXXFLAGS=-fsycl -O3 -g
```

### Issue: No SYCL device found

**Solution**: This is normal if you don't have a compatible GPU. SYCL will use CPU execution, which still works fine.

### Issue: Apple Silicon performance

**Solution**: Use hipSYCL/AdaptiveCpp instead of Intel oneAPI for native ARM performance.

## Performance Comparison

| Compiler | Intel Mac | Apple Silicon |
|----------|-----------|---------------|
| **Intel oneAPI** | ⚡ Excellent | 🐌 Slow (Rosetta 2) |
| **hipSYCL/AdaptiveCpp** | ✅ Good | ⚡ Excellent |

## Recommended Setup by Mac Type

### Intel Mac
```bash
# Use Intel oneAPI for best compatibility
source /opt/intel/oneapi/setvars.sh
cp make.inc.oneapi make.inc
make
```

### Apple Silicon Mac
```bash
# Use hipSYCL/AdaptiveCpp for best performance
cp make.inc.hipsycl.amd make.inc
# Edit make.inc to set: CXXFLAGS=-O3 --acpp-targets=omp
make
```

## Visualization

Output files can be visualized using:

```bash
# Install Python tools
pip install gdal matplotlib

# Convert output to PNG
python -m surfertools.sfg2ppm --palette sshmax.rel.cpt eWave.2D.sshmax | \
  convert -flip - sshmax.png
```

## Additional Resources

- Intel oneAPI Documentation: https://www.intel.com/content/www/us/en/docs/oneapi/
- AdaptiveCpp Documentation: https://github.com/AdaptiveCpp/AdaptiveCpp
- SYCL Specification: https://www.khronos.org/sycl/
- Original easyWave: https://git.gfz-potsdam.de/id2/geoperil/easyWave

## Why macOS is Great for This Project

1. ✅ Native Unix environment - Makefile works out-of-the-box
2. ✅ GNU Make included - no extra tools needed
3. ✅ Multiple SYCL compiler options available
4. ✅ Easy package management with Homebrew
5. ✅ Better than Windows for development workflow

## Support

For issues specific to this SYCL port, refer to the main README.md.
For compiler-specific issues:
- Intel oneAPI: Intel support forums
- hipSYCL/AdaptiveCpp: GitHub issues
