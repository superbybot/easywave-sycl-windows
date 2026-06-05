# SYCL port of easyWave

This is a SYCL port of the easyWave tsunami simulation software created by members of the Zuse Institute Berlin.
Originally, the application was developed at the German Research Center for Geosciences, Potsdam.
Please find the original version at https://git.gfz-potsdam.de/id2/geoperil/easyWave.
The repository at GFZ also contains data to use with easyWave.
The source code here has been obtained from the original CUDA code using the Intel DPC++ Compatibility Tool and was subsequently developed further.

## Important 

The primary objective of this source repository is to explore the usage of the SYCL standard and the performance of its implementations on different accelerators.
While care is taken to ensure computational correctness compared to the original source code, no guarantees can be made on this.
Therefore, no warranty is provided by the authors.
For usage in its original use-case, i.e. early warnings on tsunamis, refer the repository of GFZ.

## Usage

### Compilation

You need a SYCL compiler to build the code.
The Intel oneAPI DPC++ Compiler allows to compile the code for both Intel CPUs and GPUs as well as FPGAs.
Refer to Intel oneAPI documentation for details on the DPC++ compiler.
The open source Intel LLVM compiler (available at https://github.com/intel/llvm) can be used to compile versions for Nvidia (CUDA) and AMD GPUs as well, if the compiler is built accordingly.
According `make(1)` include files are part of this repository. 

If an appropriate SYCL compiler is available, create a link or copy the according include file and name it `make.inc`.
Running GNU make afterwards should successfully build easyWave.

### Running easyWave

To run easyWave, obtain input data from the GFZ repository first.
An execution using SYCL devices (inluding CPUs) requires the `-gpu` command line switch.
A typical run can be started as follows:

```sh
data_path="/path/to/gfz/data"
timestep=5
simulation_time=1440
propagation_time=1500 # disable intermediate outputs
grid="e2r4Pacific.grd"
fault="uz.Tohoku11.grd"

./easywave -gpu -verbose -propagate ${propagation_time} -step ${timestep} -grid "${data_path}/grids/${grid}" -source "${data_path}/faults/${fault}" -time ${simulation_time}
```

This will compute the propagation of the tsunami caused by the Tohuku earth quake in March 2011 near Japan.

### Visualization

One of the (intermediate) outputs of easyWave is a `eWave.2D.sshmax` file.
This is a Surfer Grid (grd) file.
For visualization, you may use tools like `gdal_translate` or self-containing, yet limited Python scripts like `sfg2ppm` from the [surfertools Github Repository](https://github.com/christgau/surfertools).
With the latter and a [color palette from GFZ](https://git.gfz-potsdam.de/id2/geoperil/easyWave/-/tree/master/code/tools) (.cpt files).
ImageMagick's `convert` or similar commands may be used to convert the PPM file into a PNG, and bring it into the right orientation:

```
sfg2ppm.py --palette sshmax.rel.cpt eWave.2D.sshmax | convert -flip - sshmax.png
```

## CUDA / GPU Compatibility & Future TODOs

- **CUDA Build GPU Compatibility**: By default, [build-cuda.bat](file:///c:/Users/dell/Desktop/easywave-sycl-windows/build-cuda.bat) compiles the CUDA version to support:
  - **Maxwell Architecture (`sm_52` / GTX 900 series)**: e.g., GTX 980, GTX 970, GTX 960, etc.
  - **Pascal Architecture (`sm_61` / GTX 10-series)**: e.g., GTX 1080, GTX 1070, GTX 1060, GTX 1050, etc.
  - **Newer NVIDIA GPUs (Turing, Ampere, Ada Lovelace, Blackwell, etc.)**: e.g., RTX 20-series, 30-series, 40-series, and **50-series (RTX 5060/5070/5080/5090)**. These are supported via PTX JIT (Just-In-Time) compilation, where the NVIDIA driver automatically compiles the embedded Pascal `compute_61` PTX code into native machine code at runtime.
- **CUDA 13.x Warning**: CUDA 13.x completely removes support for Maxwell, Pascal (sm_61), and Volta architectures. If compiling with CUDA 13.x or newer, compilation targeting these older GPUs will fail.
- **TODO**: In the future, migrate the codebase to support newer architectures (Turing `sm_75` and newer) natively as CUDA 13 becomes standard, or configure the build system to gracefully fallback to supported architectures based on the installed CUDA Toolkit version.
