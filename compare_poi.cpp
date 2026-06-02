#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <cmath>
#include <iomanip>
#include <algorithm>

struct Row {
    double time;
    std::vector<double> values;
};

std::vector<std::string> split(const std::string& str) {
    std::vector<std::string> tokens;
    std::string token;
    std::istringstream tokenStream(str);
    while (tokenStream >> token) {
        tokens.push_back(token);
    }
    return tokens;
}

bool read_poi_ssh(const std::string& filepath, std::vector<std::string>& headers, std::vector<Row>& rows) {
    std::ifstream file(filepath);
    if (!file) {
        std::cerr << "Error: Cannot open " << filepath << std::endl;
        return false;
    }
    std::string line;
    if (std::getline(file, line)) {
        headers = split(line);
    } else {
        std::cerr << "Error: Empty file " << filepath << std::endl;
        return false;
    }
    while (std::getline(file, line)) {
        auto tokens = split(line);
        if (tokens.empty()) continue;
        Row row;
        try {
            row.time = std::stod(tokens[0]);
            for (size_t i = 1; i < tokens.size(); ++i) {
                row.values.push_back(std::stod(tokens[i]));
            }
            rows.push_back(row);
        } catch (const std::exception& e) {
            std::cerr << "Warning: Error parsing line: " << line << " (" << e.what() << ")" << std::endl;
        }
    }
    return true;
}

int main(int argc, char** argv) {
    if (argc < 3 || argc > 4) {
        std::cerr << "Usage: compare_poi <cpu_file> <gpu_file> [tolerance]\n";
        return 2;
    }

    std::string cpu_path = argv[1];
    std::string gpu_path = argv[2];
    double tolerance = 1e-4;
    if (argc == 4) {
        tolerance = std::stod(argv[3]);
    }

    std::vector<std::string> cpu_headers, gpu_headers;
    std::vector<Row> cpu_rows, gpu_rows;

    if (!read_poi_ssh(cpu_path, cpu_headers, cpu_rows) || !read_poi_ssh(gpu_path, gpu_headers, gpu_rows)) {
        return 2;
    }

    if (cpu_headers.size() != gpu_headers.size()) {
        std::cerr << "Error: POI count mismatch. CPU has " << cpu_headers.size() - 1 
                  << " POIs, GPU has " << gpu_headers.size() - 1 << " POIs." << std::endl;
        return 1;
    }

    size_t min_rows = std::min(cpu_rows.size(), gpu_rows.size());
    if (cpu_rows.size() != gpu_rows.size()) {
        std::cout << "Warning: Row count mismatch. CPU rows=" << cpu_rows.size() 
                  << ", GPU rows=" << gpu_rows.size() << ". Comparing up to row " << min_rows << std::endl;
    }

    double max_diff = 0.0;
    double sum_diff = 0.0;
    size_t count = 0;
    size_t max_row = 0;
    size_t max_col = 0;
    double max_cpu_val = 0;
    double max_gpu_val = 0;

    for (size_t r = 0; r < min_rows; ++r) {
        if (std::abs(cpu_rows[r].time - gpu_rows[r].time) > 1e-4) {
            std::cerr << "Error: Time mismatch at row " << r << ": CPU=" << cpu_rows[r].time 
                      << ", GPU=" << gpu_rows[r].time << std::endl;
            return 1;
        }
        size_t cols_to_compare = std::min(cpu_rows[r].values.size(), gpu_rows[r].values.size());
        for (size_t c = 0; c < cols_to_compare; ++c) {
            double diff = std::abs(cpu_rows[r].values[c] - gpu_rows[r].values[c]);
            if (diff > max_diff) {
                max_diff = diff;
                max_row = r;
                max_col = c;
                max_cpu_val = cpu_rows[r].values[c];
                max_gpu_val = gpu_rows[r].values[c];
            }
            sum_diff += diff;
            count++;
        }
    }

    std::cout << "POI Analysis:\n";
    std::cout << "  Total compared data points: " << count << std::endl;
    std::cout << "  Max absolute difference   : " << std::scientific << std::setprecision(6) << max_diff << std::endl;
    if (count > 0) {
        std::cout << "  Mean absolute difference  : " << sum_diff / count << std::endl;
    }
    if (max_diff > 0 && max_col + 1 < cpu_headers.size()) {
        std::cout << "  Worst discrepancy at      : Time " << std::fixed << std::setprecision(2) 
                  << cpu_rows[max_row].time << " min, POI " << cpu_headers[max_col + 1] << std::endl;
        std::cout << "    CPU value               : " << std::fixed << std::setprecision(6) << max_cpu_val << std::endl;
        std::cout << "    GPU value               : " << max_gpu_val << std::endl;
    }

    if (max_diff <= tolerance) {
        std::cout << "Analysis: POI values match within tolerance (" << tolerance << "). PASS\n";
        return 0;
    } else {
        std::cout << "Analysis: POI values exceed tolerance (" << tolerance << "). FAIL\n";
        return 1;
    }
}
