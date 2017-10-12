#pragma once

#include <cxxopts.hpp>

namespace bpephrase {
// Copy is fine...
cxxopts::Options initOptions() {
    cxxopts::Options options("BPEPhrase", "Dis my progrem");
    options.add_options()
        ("t,train", "", cxxopts::value<std::string>())
        ("d,dev", "", cxxopts::value<std::string>())
        ("e,test", "", cxxopts::value<std::string>())
        ("o,output", "", cxxopts::value<std::string>())
        ("s,symbols", "", cxxopts::value<int>())
        ("m,minfreq", "", cxxopts::value<int>());
    return options;
}
} // ns bpephrase
