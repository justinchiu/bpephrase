#pragma once

#include <string>
#include <unordered_map>
#include <vector>
#include <fstream>
#include <sstream>
#include <tuple>

#include <boost/heap/binomial_heap.hpp>
#include <boost/functional/hash.hpp>

namespace bpephrase {
using Token = int;
using Sentence = std::vector<Token>;
using Corpus = std::vector<Sentence>;

extern char endl;
extern bool debug;

struct heap_data;
using Data = int;
using Heap = boost::heap::binomial_heap<heap_data>;
using Handle = Heap::handle_type;

using Bigram     = std::tuple<int, int>;
using Trigram    = std::tuple<int, int, int>;
using BigramMap  = std::unordered_map<Bigram, int, boost::hash<Bigram>>;
using TrigramMap = std::unordered_map<Trigram, int, boost::hash<Trigram>>;


struct heap_data {
    Handle handle;
    Data data;
    int count;

    heap_data(int id, int c) 
      : data(id), count(c) {}
    bool operator<(heap_data const & rhs) const {
        return count < rhs.count;
    }
};

struct Dictionary {
  //private:
    std::string inputFilename;
    std::string codesFilename;
    std::string outputFilename;
    Corpus corpus;

    int bos;
    int eos;
    int unk;
    int pad;

    std::unordered_map<std::string, int> word_to_id;
    std::vector<std::string> id_to_word;

    BigramMap bigram_to_id;
    std::vector<Bigram> id_to_bigram;

    TrigramMap trigram_to_id;
    std::vector<Trigram> id_to_trigram;

  //public:
    static const std::string BOS;
    static const std::string EOS;
    static const std::string UNK;
    static const std::string PAD;

    Dictionary(
      std::string inputFilename, 
      std::string codesFilename, 
      std::string outputFilename
    ) : inputFilename(inputFilename), 
        codesFilename(codesFilename), 
        outputFilename(outputFilename) {
    };

    int addWord(const std::string& token); 

    int lookupWord(const std::string& token);
    void initializeVocabulary();

    void tokenizeText(std::string filename, Corpus & corpus); 

    void getBigrams() {
    };
};

} // namespace bpephrase
