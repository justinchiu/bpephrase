#pragma once

#include <cxxopts.hpp>

namespace bpephrase {
// Copy is fine...
cxxopts::Options initOptions() {
    cxxopts::Options options("BPEPhrase", "Dis my progrem");
    options.add_options()
        ("t,train", "", cxxopts::value<std::string>())
        ("v,valid", "", cxxopts::value<std::string>())
        ("e,test", "", cxxopts::value<std::string>())
        ("p,vocab", "", cxxopts::value<std::string>())
        ("s,symbols", "", cxxopts::value<int>())
        ("m,minfreq", "", cxxopts::value<int>());
    return options;
}
} // ns bpephrase
