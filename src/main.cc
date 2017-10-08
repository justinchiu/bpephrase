#include <cxxopts.hpp>
#include <iostream>
#include <string>

#include "bpephrase/options.h"

using namespace bpephrase;

int buffer_size = 65536;

int main(int argc, char** argv) {
    cxxopts::Options options = initOptions();
    options.parse(argc, argv);
    auto endl = "\n";
    std::cout << "hello!" << endl;

    auto input = options["input"].as<std::string>();
    std::cout << input << endl;
}
