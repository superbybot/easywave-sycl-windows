import sys
import struct

def read_grd_binary(filename):
    try:
        with open(filename, 'rb') as f:
            magic = f.read(4)
            if magic != b'DSBB': return None
            nx, ny = struct.unpack('<hh', f.read(4))
            f.read(48) # skip bounds
            raw = struct.unpack(f'<{nx * ny}f', f.read(nx * ny * 4))
            return raw
    except Exception:
        return None

def main():
    if len(sys.argv) != 3:
        print("Usage: python auto_analyze.py <cpu_file> <gpu_file>")
        sys.exit(1)
        
    d1 = read_grd_binary(sys.argv[1])
    d2 = read_grd_binary(sys.argv[2])
    
    if d1 is None:
        print(f"Error: Could not read or parse {sys.argv[1]}")
        sys.exit(1)
    if d2 is None:
        print(f"Error: Could not read or parse {sys.argv[2]}")
        sys.exit(1)
    if len(d1) != len(d2):
        print(f"Error: Grid size mismatch! {len(d1)} vs {len(d2)}")
        sys.exit(1)
    
    max_diff = max(abs(a - b) for a, b in zip(d1, d2))
    print(f"Max absolute difference: {max_diff:.6e}")
    
    if max_diff <= 1e-4:
        print("Analysis: Outputs are MATCHING and CORRECT.")
        sys.exit(0)
    else:
        print("Analysis: Outputs DO NOT MATCH.")
        sys.exit(1)

if __name__ == '__main__':
    main()
