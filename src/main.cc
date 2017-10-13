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

    dictionary.learnNgrams<Bigram, BigramMap>(
        2, dictionary.trainCorpus, dictionary.bigram_to_id, dictionary.id_to_bigram);
    dictionary.learnNgrams<Trigram, TrigramMap>(
        3, dictionary.trainCorpus, dictionary.trigram_to_id, dictionary.id_to_trigram);
    dictionary.learnNgrams<Fourgram, FourgramMap>(
        4, dictionary.trainCorpus, dictionary.fourgram_to_id, dictionary.id_to_fourgram);
    dictionary.learnNgrams<Fivegram, FivegramMap>(
        5, dictionary.trainCorpus, dictionary.fivegram_to_id, dictionary.id_to_fivegram);

    std::cout << "Processing train" << std::endl;
    dictionary.getNgrams<Bigram, BigramMap>(
        2, dictionary.trainCorpus, dictionary.bigram_to_id, dictionary.id_to_bigram, train + ".bigram");
    dictionary.getNgrams<Trigram, TrigramMap>(
        3, dictionary.trainCorpus, dictionary.trigram_to_id, dictionary.id_to_trigram, train + ".trigram");
    dictionary.getNgrams<Fourgram, FourgramMap>(
        4, dictionary.trainCorpus, dictionary.fourgram_to_id, dictionary.id_to_fourgram, train + ".fourgram");
    dictionary.getNgrams<Fivegram, FivegramMap>(
        5, dictionary.trainCorpus, dictionary.fivegram_to_id, dictionary.id_to_fivegram, train + ".fivegram");

    std::cout << "Processing valid" << std::endl;
    dictionary.getNgrams<Bigram, BigramMap>(
        2, dictionary.validCorpus, dictionary.bigram_to_id, dictionary.id_to_bigram, valid + ".bigram");
    dictionary.getNgrams<Trigram, TrigramMap>(
        3, dictionary.validCorpus, dictionary.trigram_to_id, dictionary.id_to_trigram, valid + ".trigram");
    dictionary.getNgrams<Fourgram, FourgramMap>(
        4, dictionary.validCorpus, dictionary.fourgram_to_id, dictionary.id_to_fourgram, valid + ".fourgram");
    dictionary.getNgrams<Fivegram, FivegramMap>(
        5, dictionary.validCorpus, dictionary.fivegram_to_id, dictionary.id_to_fivegram, valid + ".fivegram");

    std::cout << "Processing test" << std::endl;
    dictionary.getNgrams<Bigram, BigramMap>(
        2, dictionary.testCorpus, dictionary.bigram_to_id, dictionary.id_to_bigram, test + ".bigram");
    dictionary.getNgrams<Trigram, TrigramMap>(
        3, dictionary.testCorpus, dictionary.trigram_to_id, dictionary.id_to_trigram, test + ".trigram");
    dictionary.getNgrams<Fourgram, FourgramMap>(
        4, dictionary.testCorpus, dictionary.fourgram_to_id, dictionary.id_to_fourgram, test + ".fourgram");
    dictionary.getNgrams<Fivegram, FivegramMap>(
        5, dictionary.testCorpus, dictionary.fivegram_to_id, dictionary.id_to_fivegram, test + ".fivegram");

    //dictionary.getBigrams(dictionary.trainCorpus, train);
    //dictionary.getTrigrams(dictionary.trainCorpus, train);
    //dictionary.getFourgrams(dictionary.trainCorpus, train);
    //dictionary.getFivegrams(dictionary.trainCorpus, train);

    //dictionary.getBigrams(dictionary.validCorpus, valid);
    //dictionary.getTrigrams(dictionary.validCorpus, valid);
    //dictionary.getFourgrams(dictionary.validCorpus, valid);
    //dictionary.getFivegrams(dictionary.validCorpus, valid);

    //dictionary.getBigrams(dictionary.testCorpus, test);
    //dictionary.getTrigrams(dictionary.testCorpus, test);
    //dictionary.getFourgrams(dictionary.testCorpus, test);
    //dictionary.getFivegrams(dictionary.testCorpus, test);
}
