#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cmath>
#include <algorithm>

#pragma pack(push, 1)
struct GrdHeader {
    short nx;
    short ny;
    double xlo;
    double xhi;
    double ylo;
    double yhi;
    double zlo;
    double zhi;
};
#pragma pack(pop)

struct GrdData {
    GrdHeader header;
    std::vector<float> data;

    bool load(const std::string& filename) {
        std::ifstream file(filename, std::ios::binary);
        if (!file) {
            std::cerr << "Cannot open " << filename << std::endl;
            return false;
        }
        char magic[4];
        file.read(magic, 4);
        if (std::string(magic, 4) != "DSBB") {
            std::cerr << "Not a binary GRD file: " << filename << std::endl;
            return false;
        }
        file.read(reinterpret_cast<char*>(&header), sizeof(GrdHeader));
        data.resize(header.nx * header.ny);
        file.read(reinterpret_cast<char*>(data.data()), data.size() * sizeof(float));
        return true;
    }
};

int main(int argc, char** argv) {
    if (argc < 3 || argc > 4) {
        std::cerr << "Usage: compare <file1> <file2> [tolerance]\n";
        return 2;
    }
    double tolerance = 1e-4;
    if (argc == 4) {
        tolerance = std::stod(argv[3]);
    }

    GrdData f1, f2;
    if (!f1.load(argv[1]) || !f2.load(argv[2])) return 1;

    std::cout << "File 1: " << f1.header.nx << "x" << f1.header.ny 
              << " from (" << f1.header.xlo << "," << f1.header.ylo << ") to (" 
              << f1.header.xhi << "," << f1.header.yhi << ") Z-range: ["
              << f1.header.zlo << ", " << f1.header.zhi << "]\n";
    std::cout << "File 2: " << f2.header.nx << "x" << f2.header.ny 
              << " from (" << f2.header.xlo << "," << f2.header.ylo << ") to (" 
              << f2.header.xhi << "," << f2.header.yhi << ") Z-range: ["
              << f2.header.zlo << ", " << f2.header.zhi << "]\n";

    double xlo = std::max(f1.header.xlo, f2.header.xlo);
    double xhi = std::min(f1.header.xhi, f2.header.xhi);
    double ylo = std::max(f1.header.ylo, f2.header.ylo);
    double yhi = std::min(f1.header.yhi, f2.header.yhi);

    if (xlo >= xhi || ylo >= yhi) {
        std::cout << "No overlap!\n";
        return 0;
    }

    std::cout << "Overlap: from (" << xlo << "," << ylo << ") to (" << xhi << "," << yhi << ")\n";

    double dx = (f1.header.xhi - f1.header.xlo) / (f1.header.nx - 1);
    double dy = (f1.header.yhi - f1.header.ylo) / (f1.header.ny - 1);

    int nx_overlap = std::round((xhi - xlo) / dx) + 1;
    int ny_overlap = std::round((yhi - ylo) / dy) + 1;

    int i1_start = std::round((xlo - f1.header.xlo) / dx);
    int j1_start = std::round((ylo - f1.header.ylo) / dy);
    int i2_start = std::round((xlo - f2.header.xlo) / dx);
    int j2_start = std::round((ylo - f2.header.ylo) / dy);

    float max_diff = 0;
    double sum_diff = 0;
    int count = 0;
    float max_val1 = -999999;
    float max_val2 = -999999;

    for (int j = 0; j < ny_overlap; ++j) {
        for (int i = 0; i < nx_overlap; ++i) {
            float val1 = f1.data[(j1_start + j) * f1.header.nx + (i1_start + i)];
            float val2 = f2.data[(j2_start + j) * f2.header.nx + (i2_start + i)];
            if (val1 > max_val1 && val1 != 9999) max_val1 = val1;
            if (val2 > max_val2 && val2 != 9999) max_val2 = val2;
            float diff = std::abs(val1 - val2);
            if (diff > max_diff) max_diff = diff;
            sum_diff += diff;
            count++;
        }
    }

    std::cout << "Max value in CPU overlap: " << max_val1 << "\n";
    std::cout << "Max value in GPU overlap: " << max_val2 << "\n";
    std::cout << "Max difference in overlapping region: " << max_diff << "\n";
    std::cout << "Mean difference in overlapping region: " << sum_diff / count << "\n";

    if (max_diff <= tolerance) {
        std::cout << "Analysis: Outputs are MATCHING and CORRECT.\n";
        return 0;
    } else {
        std::cout << "Analysis: Outputs DO NOT MATCH.\n";
        return 1;
    }
}
