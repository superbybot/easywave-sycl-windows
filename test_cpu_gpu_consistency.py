import os
import sys
import time
import json
import struct
import subprocess
import argparse

# Try to import numpy, but provide a pure-python fallback for maximum robustness
try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False

def read_grd_binary(filename):
    """
    Parses GoldenSoftware Binary Grid Format (DSBB) files.
    Works with numpy if available, otherwise falls back to pure Python.
    """
    if not os.path.exists(filename):
        print(f"Error: Output file not found: {filename}")
        return None

    try:
        with open(filename, 'rb') as f:
            magic = f.read(4)
            if magic != b'DSBB':
                print(f"Error: {filename} is not in DSBB binary format (magic was {magic})")
                return None
            
            # Read header
            nx, ny = struct.unpack('<hh', f.read(4))
            xlo, xhi = struct.unpack('<dd', f.read(16))
            ylo, yhi = struct.unpack('<dd', f.read(16))
            zlo, zhi = struct.unpack('<dd', f.read(16))
            
            # Read float data (nx * ny floats)
            num_elements = nx * ny
            
            if HAS_NUMPY:
                data = np.fromfile(f, dtype=np.float32, count=num_elements)
                if len(data) != num_elements:
                    print(f"Error: Expected {num_elements} floats in {filename}, read {len(data)}")
                    return None
                data = data.reshape((ny, nx))
            else:
                # Pure python fallback
                data_bytes = f.read(num_elements * 4)
                if len(data_bytes) != num_elements * 4:
                    print(f"Error: Expected {num_elements * 4} bytes in {filename}, read {len(data_bytes)}")
                    return None
                raw_data = struct.unpack(f'<{num_elements}f', data_bytes)
                # Reshape into list of lists (row-major)
                data = [list(raw_data[i*nx : (i+1)*nx]) for i in range(ny)]
                
            return {
                'nx': nx, 'ny': ny,
                'xlo': xlo, 'xhi': xhi,
                'ylo': ylo, 'yhi': yhi,
                'zlo': zlo, 'zhi': zhi,
                'data': data
            }
    except Exception as e:
        print(f"Error reading {filename}: {e}")
        return None

def run_simulation(exe, grid, source, time_min, label, use_gpu, verbose=False):
    """
    Runs the easyWave executable with the specified parameters.
    """
    cmd = [
        exe,
        "-grid", grid,
        "-source", source,
        "-time", str(time_min),
        "-label", label,
        "-progress", "1"
    ]
    if use_gpu:
        cmd.append("-gpu")
    if verbose:
        cmd.append("-verbose")
        
    print(f"Executing: {' '.join(cmd)}")
    
    start_time = time.perf_counter()
    
    # Run process and redirect output
    log_filename = f"run_{label}.log"
    with open(log_filename, 'w') as log_file:
        try:
            result = subprocess.run(
                cmd,
                stdout=log_file,
                stderr=subprocess.STDOUT,
                text=True,
                check=True
            )
            success = (result.returncode == 0)
        except subprocess.CalledProcessError as e:
            print(f"\nExecution failed for command: {' '.join(cmd)}")
            print(f"Check log file: {log_filename}")
            return False, 0.0
            
    elapsed = time.perf_counter() - start_time
    return True, elapsed

def compare_grids(cpu_grid, gpu_grid):
    """
    Computes differences between CPU and GPU grids.
    Supports both numpy and pure Python representations.
    """
    nx = cpu_grid['nx']
    ny = cpu_grid['ny']
    
    if nx != gpu_grid['nx'] or ny != gpu_grid['ny']:
        print(f"Grid dimensions mismatch! CPU: {nx}x{ny}, GPU: {gpu_grid['nx']}x{gpu_grid['ny']}")
        return None
        
    if HAS_NUMPY:
        c_data = cpu_grid['data']
        g_data = gpu_grid['data']
        
        diff = np.abs(c_data - g_data)
        max_diff = float(np.max(diff))
        mean_diff = float(np.mean(diff))
        rmse = float(np.sqrt(np.mean(diff ** 2)))
        
        # Find where maximum difference occurs
        max_idx = np.unravel_index(np.argmax(diff), diff.shape)
        max_y, max_x = int(max_idx[0]), int(max_idx[1])
        c_val = float(c_data[max_y, max_x])
        g_val = float(g_data[max_y, max_x])
        
        # Cumulative histogram counts
        count_total = int(diff.size)
        count_e5 = int(np.sum(diff > 1e-5))
        count_e4 = int(np.sum(diff > 1e-4))
        count_e3 = int(np.sum(diff > 1e-3))
        count_e2 = int(np.sum(diff > 1e-2))
        count_e1 = int(np.sum(diff > 1e-1))
    else:
        # Pure Python fallback
        c_data = cpu_grid['data']
        g_data = gpu_grid['data']
        
        max_diff = 0.0
        sum_diff = 0.0
        sum_sq_diff = 0.0
        max_x, max_y = 0, 0
        c_val, g_val = 0.0, 0.0
        
        count_total = nx * ny
        count_e5 = 0
        count_e4 = 0
        count_e3 = 0
        count_e2 = 0
        count_e1 = 0
        
        for y in range(ny):
            for x in range(nx):
                val1 = c_data[y][x]
                val2 = g_data[y][x]
                d = abs(val1 - val2)
                
                if d > max_diff:
                    max_diff = d
                    max_x = x
                    max_y = y
                    c_val = val1
                    g_val = val2
                    
                sum_diff += d
                sum_sq_diff += d * d
                
                if d > 1e-5: count_e5 += 1
                if d > 1e-4: count_e4 += 1
                if d > 1e-3: count_e3 += 1
                if d > 1e-2: count_e2 += 1
                if d > 1e-1: count_e1 += 1
                
        mean_diff = sum_diff / count_total
        rmse = (sum_sq_diff / count_total) ** 0.5
        
    return {
        'max_diff': max_diff,
        'max_diff_loc': (max_x, max_y),
        'cpu_val_at_max': c_val,
        'gpu_val_at_max': g_val,
        'mean_diff': mean_diff,
        'rmse': rmse,
        'cell_counts': {
            'total': count_total,
            'exceed_1e-5': count_e5,
            'exceed_1e-4': count_e4,
            'exceed_1e-3': count_e3,
            'exceed_1e-2': count_e2,
            'exceed_1e-1': count_e1
        }
    }

def print_dashboard(metrics, cpu_time, gpu_time, tolerance):
    """
    Renders an aesthetic ASCII comparison report dashboard.
    """
    speedup = cpu_time / gpu_time if gpu_time > 0 else 0
    passed = metrics['max_diff'] <= tolerance
    verdict = "PASSED" if passed else "FAILED"
    color_verdict = f"\033[92;1m{verdict}\033[0m" if passed else f"\033[91;1m{verdict}\033[0m"
    
    # Strip ANSI colors if writing to files or if on standard windows terminal without ANSI support
    if os.name == 'nt':
        # Simple check/setup for ANSI escape sequence support on Windows
        os.system('') 
        
    print("\n" + "="*60)
    print("           EASYWAVE CPU VS GPU CONSISTENCY REPORT")
    print("="*60)
    print(f"  Grid Dimensions : {metrics['cell_counts']['total']} cells")
    print(f"  Simulation Time : 10 minutes model time")
    print("-"*60)
    print(f"  CPU Execution   : {cpu_time:.3f} seconds")
    print(f"  GPU Execution   : {gpu_time:.3f} seconds")
    print(f"  GPU Speedup     : {speedup:.2f}x")
    print("-"*60)
    print(f"  Max Absolute Diff (L-inf) : {metrics['max_diff']:.6e}")
    print(f"  Mean Absolute Diff (L-1)  : {metrics['mean_diff']:.6e}")
    print(f"  Root Mean Square Error    : {metrics['rmse']:.6e}")
    print(f"  Worst discrepancy loc     : Grid index ({metrics['max_diff_loc'][0]}, {metrics['max_diff_loc'][1]})")
    print(f"    CPU value at loc        : {metrics['cpu_val_at_max']:.6f}")
    print(f"    GPU value at loc        : {metrics['gpu_val_at_max']:.6f}")
    print("-"*60)
    print("  Error Distribution:")
    print(f"    Diff > 10^-5            : {metrics['cell_counts']['exceed_1e-5']} cells ({metrics['cell_counts']['exceed_1e-5']/metrics['cell_counts']['total']*100:.4f}%)")
    print(f"    Diff > 10^-4            : {metrics['cell_counts']['exceed_1e-4']} cells ({metrics['cell_counts']['exceed_1e-4']/metrics['cell_counts']['total']*100:.4f}%)")
    print(f"    Diff > 10^-3            : {metrics['cell_counts']['exceed_1e-3']} cells ({metrics['cell_counts']['exceed_1e-3']/metrics['cell_counts']['total']*100:.4f}%)")
    print(f"    Diff > 10^-2            : {metrics['cell_counts']['exceed_1e-2']} cells ({metrics['cell_counts']['exceed_1e-2']/metrics['cell_counts']['total']*100:.4f}%)")
    print(f"    Diff > 10^-1            : {metrics['cell_counts']['exceed_1e-1']} cells ({metrics['cell_counts']['exceed_1e-1']/metrics['cell_counts']['total']*100:.4f}%)")
    print("="*60)
    print(f"  Configured Max Tolerance  : {tolerance:.6e}")
    print(f"  VERDICT                   : {color_verdict}")
    print("="*60 + "\n")

def main():
    parser = argparse.ArgumentParser(description="Runs easyWave CPU and GPU consistency validation test case.")
    parser.add_argument("--grid", "-g", default="easyWave-master-data/data/grids/e2r4Asean.grd", help="Path to bathymetry grid (.grd)")
    parser.add_argument("--source", "-s", default="easyWave-master-data/data/faults/fault.inp", help="Path to fault source file (.inp/.flt)")
    parser.add_argument("--time", "-t", type=int, default=10, help="Simulation duration in minutes (default: 10)")
    parser.add_argument("--cpu-exe", default="build/easywave-sycl.exe", help="EasyWave CPU executable path")
    parser.add_argument("--gpu-exe", default="build/easywave-cuda.exe", help="EasyWave GPU executable path")
    parser.add_argument("--tolerance", "-tol", type=float, default=1e-4, help="Validation tolerance threshold for PASS/FAIL (default: 1e-4)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Print verbose easyWave output to standard out")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.cpu_exe):
        print(f"Error: CPU Executable not found at '{args.cpu_exe}'. Make sure you compile it first.")
        sys.exit(1)
    if not os.path.exists(args.gpu_exe):
        print(f"Error: GPU Executable not found at '{args.gpu_exe}'. Make sure you compile it first.")
        sys.exit(1)
        
    print("Starting consistency validation test case...")
    print(f"  Using Grid   : {args.grid}")
    print(f"  Using Source : {args.source}")
    print(f"  Using CPU Exe: {args.cpu_exe}")
    print(f"  Using GPU Exe: {args.gpu_exe}")
    
    cpu_label = "test_CPU"
    gpu_label = "test_GPU"
    
    # Ensure previous output files are deleted to guarantee a clean run
    for label in [cpu_label, gpu_label]:
        for ext in [".2D.sshmax", ".2D.time", ".2D.idx"]:
            filepath = f"{label}{ext}"
            if os.path.exists(filepath):
                try:
                    os.remove(filepath)
                except OSError:
                    pass
                    
    # 1. Run CPU simulation
    print("\n--- Running CPU simulation (reference)...")
    cpu_success, cpu_time = run_simulation(args.cpu_exe, args.grid, args.source, args.time, cpu_label, use_gpu=False, verbose=args.verbose)
    if not cpu_success:
        print("Error: CPU run failed. Consistency check aborted.")
        sys.exit(1)
    print(f"CPU simulation completed in {cpu_time:.3f} seconds.")
    
    # 2. Run GPU simulation
    print("\n--- Running GPU simulation (accelerated)...")
    gpu_success, gpu_time = run_simulation(args.gpu_exe, args.grid, args.source, args.time, gpu_label, use_gpu=True, verbose=args.verbose)
    if not gpu_success:
        print("Error: GPU run failed. Consistency check aborted.")
        sys.exit(1)
    print(f"GPU simulation completed in {gpu_time:.3f} seconds.")
    
    # 3. Load outputs
    print("\n--- Loading output binary grid files (.sshmax)...")
    cpu_grid_file = f"{cpu_label}.2D.sshmax"
    gpu_grid_file = f"{gpu_label}.2D.sshmax"
    
    cpu_grid = read_grd_binary(cpu_grid_file)
    gpu_grid = read_grd_binary(gpu_grid_file)
    
    if cpu_grid is None or gpu_grid is None:
        print("Error: Failed to load one or both output grids. Consistency check aborted.")
        sys.exit(1)
        
    # 4. Compare grids
    print("\n--- Comparing grids cell by cell...")
    metrics = compare_grids(cpu_grid, gpu_grid)
    
    if metrics is None:
        print("Error: Comparison failed.")
        sys.exit(1)
        
    # 5. Output Report
    print_dashboard(metrics, cpu_time, gpu_time, args.tolerance)
    
    # 6. Save JSON report
    report = {
        'grid_file': args.grid,
        'source_file': args.source,
        'simulation_time_min': args.time,
        'cpu_runtime_sec': cpu_time,
        'gpu_runtime_sec': gpu_time,
        'speedup': cpu_time / gpu_time if gpu_time > 0 else 0.0,
        'max_diff': metrics['max_diff'],
        'mean_diff': metrics['mean_diff'],
        'rmse': metrics['rmse'],
        'worst_discrepancy_loc': metrics['max_diff_loc'],
        'cpu_val_at_max': metrics['cpu_val_at_max'],
        'gpu_val_at_max': metrics['gpu_val_at_max'],
        'cell_counts': metrics['cell_counts'],
        'tolerance_threshold': args.tolerance,
        'passed': metrics['max_diff'] <= args.tolerance,
        'has_numpy': HAS_NUMPY
    }
    
    with open('test_report.json', 'w') as f:
        json.dump(report, f, indent=4)
        
    print("Detailed report saved to: test_report.json")
    
    # Exit with code 0 if passed, 1 if failed
    if report['passed']:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
