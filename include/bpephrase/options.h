#pragma once

#include <cxxopts.hpp>

namespace bpephrase {
// Copy is fine...
cxxopts::Options initOptions() {
    cxxopts::Options options("BPEPhrase", "Dis my progrem");
    options.add_options()
        ("i,input", "", cxxopts::value<std::string>())
        ("o,output", "", cxxopts::value<std::string>())
        ("s,symbols", "", cxxopts::value<int>())
        ("m,minfreq", "", cxxopts::value<int>());
    return options;
}
} // ns bpephrase
