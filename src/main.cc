#include <cxxopts.hpp>
#include <iostream>
#include <fstream>
#include <string>

#include "bpephrase/options.h"
#include "bpephrase/dictionary.h"

using namespace bpephrase;

int buffer_size = 65536;

int main(int argc, char** argv) {
    cxxopts::Options options = initOptions();
    options.parse(argc, argv);
    std::cout << "hello!" << endl;

    auto input = options["input"].as<std::string>();
    std::cout << "Input file: " << input << endl;
    auto codes = options["codes"].as<std::string>();
    std::cout << "Codes file: " << codes << endl;
    auto output = options["output"].as<std::string>();
    std::cout << "Output file: " << output << endl;

    Dictionary dictionary(input, codes, output);
    dictionary.tokenizeText(dictionary.inputFilename, dictionary.corpus);
    //dictionary.getBigrams();
    //dictionary.getTrigrams();
    //dictionary.getFourgrams();
    dictionary.getFivegrams();
}
