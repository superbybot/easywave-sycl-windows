import struct
import sys
import numpy as np

def read_grd(filename):
    with open(filename, 'rb') as f:
        # GoldenSoftware GRD format (DSAA or DSRB)
        magic = f.read(4)
        if magic == b'DSBB':
            # Binary format
            nx, ny = struct.unpack('<hh', f.read(4))
            xlo, xhi = struct.unpack('<dd', f.read(16))
            ylo, yhi = struct.unpack('<dd', f.read(16))
            zlo, zhi = struct.unpack('<dd', f.read(16))
            data = np.fromfile(f, dtype=np.float32)
            data = data.reshape((ny, nx))
            return {'nx': nx, 'ny': ny, 'xlo': xlo, 'xhi': xhi, 'ylo': ylo, 'yhi': yhi, 'data': data}
        else:
            print(f"Unknown format or text format not supported for {filename}")
            return None

def main():
    if len(sys.argv) != 3:
        print("Usage: python compare.py <file1> <file2>")
        return

    f1 = read_grd(sys.argv[1])
    f2 = read_grd(sys.argv[2])

    if f1 is None or f2 is None:
        return

    print(f"File 1 ({sys.argv[1]}): {f1['nx']}x{f1['ny']} from ({f1['xlo']}, {f1['ylo']}) to ({f1['xhi']}, {f1['yhi']})")
    print(f"File 2 ({sys.argv[2]}): {f2['nx']}x{f2['ny']} from ({f2['xlo']}, {f2['ylo']}) to ({f2['xhi']}, {f2['yhi']})")

    # Find overlapping region
    xlo = max(f1['xlo'], f2['xlo'])
    xhi = min(f1['xhi'], f2['xhi'])
    ylo = max(f1['ylo'], f2['ylo'])
    yhi = min(f1['yhi'], f2['yhi'])

    if xlo >= xhi or ylo >= yhi:
        print("No overlap!")
        return

    print(f"Overlap: from ({xlo}, {ylo}) to ({xhi}, {yhi})")

    # Assuming dx and dy are the same
    dx = (f1['xhi'] - f1['xlo']) / (f1['nx'] - 1)
    dy = (f1['yhi'] - f1['ylo']) / (f1['ny'] - 1)

    i1_start = int(round((xlo - f1['xlo']) / dx))
    j1_start = int(round((ylo - f1['ylo']) / dy))
    i2_start = int(round((xlo - f2['xlo']) / dx))
    j2_start = int(round((ylo - f2['ylo']) / dy))

    nx_overlap = int(round((xhi - xlo) / dx)) + 1
    ny_overlap = int(round((yhi - ylo) / dy)) + 1

    d1 = f1['data'][j1_start:j1_start+ny_overlap, i1_start:i1_start+nx_overlap]
    d2 = f2['data'][j2_start:j2_start+ny_overlap, i2_start:i2_start+nx_overlap]

    diff = np.abs(d1 - d2)
    max_diff = np.max(diff)
    mean_diff = np.mean(diff)

    print(f"Max difference in overlapping region: {max_diff}")
    print(f"Mean difference in overlapping region: {mean_diff}")

if __name__ == '__main__':
    main()
