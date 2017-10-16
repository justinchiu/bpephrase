#pragma once

#include <iostream>

#include <algorithm>
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
using Heap = boost::heap::binomial_heap<heap_data>;
using Handle = Heap::handle_type;
using Handles = std::vector<Handle>;

using Bigram      = std::array<int, 2>;
using Trigram     = std::array<int, 3>;
using Fourgram    = std::array<int, 4>;
using Fivegram    = std::array<int, 5>;

using BigramMap   = std::unordered_map<Bigram, int, boost::hash<Bigram>>;
using TrigramMap  = std::unordered_map<Trigram, int, boost::hash<Trigram>>;
using FourgramMap = std::unordered_map<Fourgram, int, boost::hash<Fourgram>>;
using FivegramMap = std::unordered_map<Fivegram, int, boost::hash<Fivegram>>;

// Use this later.
template <int N>
struct Ngram {
    std::unordered_map<std::array<int, N>, int, boost::hash<std::array<int, N>>> ngram_to_id;
    std::vector<std::array<int, N>> id_to_ngram;
};

struct heap_data {
    //Handle handle;
    int data;
    int count;

    heap_data(int id, int c) : data(id), count(c) {}
    bool operator<(heap_data const & rhs) const {
        return count < rhs.count;
    }
};

struct Dictionary {
  //private:
    std::string trainFilename;
    std::string validFilename;
    std::string testFilename;
    std::string vocabFilename;
    Corpus trainCorpus, validCorpus, testCorpus;

    int bos;
    int eos;
    int unk;
    int pad;

    std::unordered_map<std::string, int> word_to_id;
    std::vector<std::string> id_to_word;

    BigramMap   bigram_to_id;
    TrigramMap  trigram_to_id;
    FourgramMap fourgram_to_id;
    FivegramMap fivegram_to_id;

    std::vector<Bigram>   id_to_bigram;
    std::vector<Trigram>  id_to_trigram;
    std::vector<Fourgram> id_to_fourgram;
    std::vector<Fivegram> id_to_fivegram;

  //public:
    static const std::string BOS;
    static const std::string EOS;
    static const std::string UNK;
    static const std::string PAD;

    Dictionary(
      std::string trainFilename, 
      std::string validFilename, 
      std::string testFilename, 
      std::string vocabFilename
    ) : trainFilename(trainFilename), 
        validFilename(validFilename),
        testFilename(testFilename),
        vocabFilename(vocabFilename) {
    };

    int addWord(const std::string& token); 

    int lookupWord(const std::string& token);
    void initializeVocabulary();
    void learnVocabulary(std::string filename);

    void tokenizeText(std::string filename, Corpus & corpus); 

    void loadVocabulary(std::string filename) {
        // Don't call initializeVocabulary here since other libraries
        // may do weird things.
        id_to_word.clear();
        word_to_id.clear();

        std::ifstream ifs(filename, std::ios::binary);
        ifs.seekg(0, std::ios::end);
        std::streampos length = ifs.tellg();
        ifs.seekg(0, std::ios::beg);

        std::vector<char> buffer(length);
        ifs.read(&buffer[0], length);
        std::istringstream iss(std::string(buffer.begin(), buffer.end()));

        // We expect input of the format:
        // id\ttoken\n

        // First we count the vocab size.
        int vocabsize = 0;
        for (const char & c : buffer) {
            if (c == '\t') { ++vocabsize; }
        }
        id_to_word.resize(vocabsize);

        int id;
        std::string token;
        while (iss >> id) {
            std::getline(iss >> std::ws, token, '\n');
            id_to_word[id] = token;
            word_to_id[token] = id;
        }
    }

    void saveTokenization() {
        std::string tokenFilename = trainFilename + ".tokenization";
        std::ofstream tokenFs(tokenFilename, std::ios::binary);

        std::stringstream tss;
        int i = 0;
        for (const auto & token : id_to_word) {
            tss << i << '\t' << token << endl;;
            ++i;
        }
        std::string tokenOut = tss.str();
        tokenFs.write(tokenOut.c_str(), tokenOut.size());

        std::string trainF = trainFilename + ".tok";
        std::ofstream trainFs(trainF, std::ios::binary);
        for (const auto & sentence : trainCorpus) {
            std::copy(sentence.begin(), sentence.end(),
                std::ostream_iterator<int>(trainFs, ","));
            trainFs << '\n';
        }

        std::string validF = validFilename + ".tok";
        std::ofstream validFs(validF, std::ios::binary);
        for (const auto & sentence : validCorpus) {
            std::copy(sentence.begin(), sentence.end(),
                std::ostream_iterator<int>(validFs, ","));
            validFs << '\n';
        }

        std::string testF = testFilename + ".tok";
        std::ofstream testFs(testF, std::ios::binary);
        for (const auto & sentence : testCorpus) {
            std::copy(sentence.begin(), sentence.end(),
                std::ostream_iterator<int>(testFs, ","));
            testFs << '\n';
        }
    }

    template <typename Ngram>
    void extractNToFile(
        int n, Heap & heap, 
        std::string filename, 
        const std::vector<Ngram> & id_to_ngram
    ) {
        std::ofstream ofs(filename, std::ios::binary);
        for (int i = 0; i < n && !heap.empty(); ++i) {
            int id = heap.top().data;
            int count = heap.top().count;
            heap.pop();
            Ngram ngram = id_to_ngram[id];
            std::stringstream ss;
            ss << i << '\t' << count << '\t';
            for (const auto & id : ngram) {
                ss << id << ' ';
            }
            ss << endl;
            std::string out = ss.str();
            ofs.write(out.c_str(), out.size());
        }
    }

    template <typename Ngram, typename MapT>
    void learnNgrams(int n, const Corpus& corpus, MapT & ngram_to_id, std::vector<Ngram> & id_to_ngram) {
        std::cout << n << std::endl;
        Ngram ngram;
        for (const auto & s : corpus) {
            if (s.size() < n) continue;
            auto first = s.begin();
            while (first+n-1 != s.end()) {
                std::copy(first, first+n, ngram.begin());
                typename MapT::iterator it = ngram_to_id.find(ngram);
                if (it == ngram_to_id.end()) {
                    // do shit!!
                    ngram_to_id.insert({ngram, id_to_ngram.size()});
                    id_to_ngram.push_back(ngram);
                }
                ++first;
            }
        }
    }

    template <typename Ngram, typename MapT>
    void getNgrams(
        int n, Corpus& corpus, MapT & ngram_to_id, std::vector<Ngram> & id_to_ngram, std::string filename) {
        std::cout << n << std::endl;
        Heap heap;
        Handles handles;
        std::unordered_map<int, Handle> handle_map;
        Ngram ngram;
        for (const auto & s : corpus) {
            if (s.size() < n) continue;
            auto first = s.begin();
            while (first+n-1 != s.end()) {
                std::copy(first, first+n, ngram.begin());
                typename MapT::iterator it = ngram_to_id.find(ngram);
                if (it == ngram_to_id.end()) {
                    // don't do shit!!
                } else {
                    int id = it->second;
                    auto handle_it = handle_map.find(id);
                    if (handle_it == handle_map.end()) {
                        // No such handle, insert into heap.
                        Handle h = heap.push(heap_data(id, 1));
                        handle_map.insert({id, h});
                    } else {
                        Handle h = handle_it->second;
                        ++(*h).count;
                        heap.increase(h);
                    }
                }
                ++first;
            }
        }
        extractNToFile<Ngram>(10000, heap, filename, id_to_ngram);
    }
};

} // namespace bpephrase
