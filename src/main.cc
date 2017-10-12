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

    auto train= options["train"].as<std::string>();
    std::cout << "Train file: " << train<< endl;
    auto valid= options["valid"].as<std::string>();
    std::cout << "Valid file: " << valid << endl;
    auto test= options["test"].as<std::string>();
    std::cout << "Test file: " << test << endl;
    auto output = options["output"].as<std::string>();
    std::cout << "Output file: " << output << endl;

    Dictionary dictionary(train, valid, test, output);

    dictionary.learnVocabulary(dictionary.trainFilename);

    dictionary.tokenizeText(dictionary.trainFilename, dictionary.trainCorpus);
    dictionary.tokenizeText(dictionary.validFilename, dictionary.validCorpus);
    dictionary.tokenizeText(dictionary.testFilename, dictionary.testCorpus);

    dictionary.saveTokenization();

    dictionary.getBigrams(dictionary.trainCorpus, train);
    dictionary.getTrigrams(dictionary.trainCorpus, train);
    dictionary.getFourgrams(dictionary.trainCorpus, train);
    dictionary.getFivegrams(dictionary.trainCorpus, train);

    dictionary.getBigrams(dictionary.validCorpus, valid);
    dictionary.getTrigrams(dictionary.validCorpus, valid);
    dictionary.getFourgrams(dictionary.validCorpus, valid);
    dictionary.getFivegrams(dictionary.validCorpus, valid);

    dictionary.getBigrams(dictionary.testCorpus, test);
    dictionary.getTrigrams(dictionary.testCorpus, test);
    dictionary.getFourgrams(dictionary.testCorpus, test);
    dictionary.getFivegrams(dictionary.testCorpus, test);
}
