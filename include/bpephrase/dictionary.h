#pragma once

#include <iostream>

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
using Handles = std::vector<Handle>;

using Bigram      = std::tuple<int, int>;
using Trigram     = std::tuple<int, int, int>;
using Fourgram    = std::tuple<int, int, int, int>;
using Fivegram    = std::tuple<int, int, int, int, int>;
using BigramMap   = std::unordered_map<Bigram, int, boost::hash<Bigram>>;
using TrigramMap  = std::unordered_map<Trigram, int, boost::hash<Trigram>>;
using FourgramMap = std::unordered_map<Fourgram, int, boost::hash<Fourgram>>;
using FivegramMap = std::unordered_map<Fivegram, int, boost::hash<Fivegram>>;

template <int N>
struct Ngram {
    std::unordered_map<std::array<int, N>, int, boost::hash<std::array<int, N>>> ngram_to_id;
    std::vector<std::array<int, N>> id_to_ngram;
};

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
    FourgramMap fourgram_to_id;
    std::vector<Fourgram> id_to_fourgram;
    FivegramMap fivegram_to_id;
    std::vector<Fivegram> id_to_fivegram;

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
        Heap heap{};
        Handles handles{};

        for (const auto& s : corpus) {
            if (s.size() < 1) continue;
            auto first = s.begin();
            auto second = ++s.begin();
            BigramMap::iterator it;
            while (second != s.end()) {
                if ((it = bigram_to_id.find({*first, *second})) == bigram_to_id.end()) {
                    int id = id_to_bigram.size();
                    bigram_to_id.insert({{*first, *second}, id});
                    id_to_bigram.push_back({*first, *second});
                    Handle h = heap.push(heap_data(id, 1));
                    handles.push_back(h);
                } else {
                    Handle h = handles[it->second];
                    ++(*h).count;
                    heap.increase(h);
                }
                ++first;
                ++second;
            }
        }
        std::cout << "Found " << id_to_bigram.size() << " bigrams" << endl;
        for (int i = 0; i < 10000 && !heap.empty(); ++i) {
            int id = heap.top().data;
            int count = heap.top().count;
            Bigram bigram = id_to_bigram[id];
            std::cout << i << ' ' << count << ": " << id_to_word[std::get<0>(bigram)] 
            << ' ' << id_to_word[std::get<1>(bigram)] << endl;
            heap.pop();
        }
    };

    void getTrigrams() {
        Heap heap{};
        Handles handles{};

        for (const auto& s : corpus) {
            if (s.size() < 3) continue;
            auto first = s.begin();
            auto second = ++s.begin();
            auto third = ++++s.begin();
            TrigramMap::iterator it;
            while (third != s.end()) {
                if ((it = trigram_to_id.find({*first, *second, *third})) == trigram_to_id.end()) {
                    int id = id_to_trigram.size();
                    trigram_to_id.insert({{*first, *second, *third}, id});
                    id_to_trigram.push_back({*first, *second, *third});
                    Handle h = heap.push(heap_data(id, 1));
                    handles.push_back(h);
                } else {
                    Handle h = handles[it->second];
                    ++(*h).count;
                    heap.increase(h);
                }
                ++first;
                ++second;
                ++third;
            }
        }
        std::cout << "Found " << id_to_trigram.size() << " trigrams" << endl;
        for (int i = 0; i < 10000 && !heap.empty(); ++i) {
            int id = heap.top().data;
            int count = heap.top().count;
            Trigram trigram = id_to_trigram[id];
            std::cout << i << ' ' << count << ": " << id_to_word[std::get<0>(trigram)] 
            << ' ' << id_to_word[std::get<1>(trigram)] << ' ' << id_to_word[std::get<2>(trigram)]<< endl;
            heap.pop();
        }
    };


    void getFourgrams() {
        Heap heap{};
        Handles handles{};

        for (const auto& s : corpus) {
            if (s.size() < 4) continue;
            auto first = s.begin();
            auto second = s.begin() + 1;
            auto third = s.begin() + 2;
            auto fourth = s.begin() + 3;
            FourgramMap::iterator it;
            while (fourth != s.end()) {
                if ((it = fourgram_to_id.find({*first, *second, *third, *fourth})) == fourgram_to_id.end()) {
                    int id = id_to_fourgram.size();
                    fourgram_to_id.insert({{*first, *second, *third, *fourth}, id});
                    id_to_fourgram.push_back({*first, *second, *third, *fourth});
                    Handle h = heap.push(heap_data(id, 1));
                    handles.push_back(h);
                } else {
                    Handle h = handles[it->second];
                    ++(*h).count;
                    heap.increase(h);
                }
                ++first;
                ++second;
                ++third;
                ++fourth;
            }
        }
        std::cout << "Found " << id_to_fourgram.size() << " fourgrams" << endl;
        for (int i = 0; i < 10000 && !heap.empty(); ++i) {
            int id = heap.top().data;
            int count = heap.top().count;
            Fourgram fourgram = id_to_fourgram[id];
            std::cout << i << ' ' << count << ": " << id_to_word[std::get<0>(fourgram)] 
            << ' ' << id_to_word[std::get<1>(fourgram)] 
            << ' ' << id_to_word[std::get<2>(fourgram)]
            << ' ' << id_to_word[std::get<3>(fourgram)]
            << endl;
            heap.pop();
        }
    };

    void getFivegrams() {
        Heap heap{};
        Handles handles{};

        for (const auto& s : corpus) {
            if (s.size() < 5) continue;
            auto first = s.begin();
            auto second = s.begin() + 1;
            auto third = s.begin() + 2;
            auto fourth = s.begin() + 3;
            auto fifth = s.begin() + 4;
            FivegramMap::iterator it;
            while (fifth != s.end()) {
                if ((it = fivegram_to_id.find({*first, *second, *third, *fourth, *fifth})) == fivegram_to_id.end()) {
                    int id = id_to_fivegram.size();
                    fivegram_to_id.insert({{*first, *second, *third, *fourth, *fifth}, id});
                    id_to_fivegram.push_back({*first, *second, *third, *fourth, *fifth});
                    Handle h = heap.push(heap_data(id, 1));
                    handles.push_back(h);
                } else {
                    Handle h = handles[it->second];
                    ++(*h).count;
                    heap.increase(h);
                }
                ++first;
                ++second;
                ++third;
                ++fourth;
                ++fifth;
            }
        }
        std::cout << "Found " << id_to_fivegram.size() << " fivegrams" << endl;
        for (int i = 0; i < 10000 && !heap.empty(); ++i) {
            int id = heap.top().data;
            int count = heap.top().count;
            Fivegram fivegram = id_to_fivegram[id];
            std::cout << i << ' ' << count << ": " << id_to_word[std::get<0>(fivegram)] 
            << ' ' << id_to_word[std::get<1>(fivegram)] 
            << ' ' << id_to_word[std::get<2>(fivegram)]
            << ' ' << id_to_word[std::get<3>(fivegram)]
            << ' ' << id_to_word[std::get<4>(fivegram)]
            << endl;
            heap.pop();
        }
    };
};

} // namespace bpephrase
