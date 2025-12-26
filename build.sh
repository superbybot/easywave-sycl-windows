#!/bin/bash
# Build script for easyWave SYCL on Windows using MSYS2 + Intel oneAPI

echo "=========================================="
echo "Building easyWave SYCL"
echo "=========================================="

# Set up Intel oneAPI environment manually for MSYS2
echo "Setting up Intel oneAPI environment..."
export ONEAPI_ROOT="/c/Program Files (x86)/Intel/oneAPI"
export PATH="$ONEAPI_ROOT/compiler/latest/bin:$PATH"
export PATH="$ONEAPI_ROOT/compiler/latest/bin/compiler:$PATH"
export CPATH="$ONEAPI_ROOT/compiler/latest/include:$CPATH"
export LIBRARY_PATH="$ONEAPI_ROOT/compiler/latest/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$ONEAPI_ROOT/compiler/latest/lib:$LD_LIBRARY_PATH"

# Check if compiler is available
echo "Checking compiler..."
which icpx
if [ $? -ne 0 ]; then
    echo "ERROR: icpx compiler not found!"
    echo "Please make sure Intel oneAPI is installed and setvars.sh is sourced."
    exit 1
fi

echo "Compiler version:"
icpx --version

# Navigate to project directory
cd /c/Users/Wonderfy149/Documents/easywave-sycl-windows

# Check if make.inc exists
if [ ! -f "make.inc" ]; then
    echo "Creating make.inc from make.inc.oneapi..."
    cp make.inc.oneapi make.inc
fi

# Clean previous build
echo ""
echo "Cleaning previous build..."
make clean

# Build the project
echo ""
echo "Building easyWave SYCL..."
make

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Build successful!"
    echo "=========================================="
    echo ""
    echo "Executable: easywave-sycl"
    echo ""
    echo "To run:"
    echo "  ./easywave-sycl -gpu -verbose"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "Build failed!"
    echo "=========================================="
    exit 1
fi
