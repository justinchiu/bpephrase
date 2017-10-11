#pragma once

#include <string>
#include <unordered_map>
#include <vector>
#include <fstream>
#include <sstream>

namespace bpephrase {
using Token = int;
using Sentence = std::vector<Token>;
using Corpus = std::vector<Sentence>;

char endl = '\n';

bool debug = false;

class Dictionary {
  private:
    std::string inputFilename_;
    std::string codesFilename_;
    std::string outputFilename_;
    Corpus corpus_;
    std::unordered_map<std::string, int> word_to_id;
    std::vector<std::string> id_to_word;

  public:
    static const std::string BOS;
    static const std::string EOS;

    Dictionary(
      std::string inputFilename, 
      std::string codesFilename, 
      std::string outputFilename
    ) : inputFilename_(std::move(inputFilename)), 
        codesFilename_(std::move(codesFilename)), 
        outputFilename_(std::move(outputFilename)) {
    };

    int addWord(const std::string& token) {
        int id;
        auto it = word_to_id.find(token);
        if (it == word_to_id.end()) {
            id = id_to_word.size();
            word_to_id.insert({token, id_to_word.size()});
            id_to_word.push_back(token);
        } else {
            id = it->second;
        }
        return id;
    }

    void tokenizeText() {
        std::ifstream ifs(inputFilename_);
        if (ifs) {
            ifs.seekg(0, std::ios::end);
            std::streampos length = ifs.tellg();
            ifs.seekg(0, std::ios::beg);

            // load into memory
            std::vector<char> buffer(length);
            ifs.read(&buffer[0], length);

            // premature optimization
            //std::stringstream localstream;
            //localstream.rdbuf()->pubsetbuf(&buffer[0], length);

            std::string token;
            std::vector<char>::iterator begin = buffer.begin();
            std::vector<char>::iterator end = buffer.begin();
            Sentence sentence;
            sentence.reserve(64);
            bool within_word = false;
            while (end != buffer.end()) {
                if (*end == ' ' || *end == '\t' || *end == '\r') {
                    if (within_word) {
                        // If this is the end of word then we need to add the token.
                        // Just copy everything, it's fine.
                        token.assign(begin, end);
                        int id = addWord(token);
                        sentence.push_back(id);
                    }
                    // Ignore these characters and move begin to ++end.
                    ++end;
                    begin = end;
                    within_word = false;
                } else if (*end == '\n') {
                    if (within_word) {
                        token.assign(begin, end);
                        int id = addWord(token);
                        sentence.push_back(id);
                    }
                    if (!sentence.empty()) {
                        corpus_.emplace_back(std::move(sentence));
                        sentence.clear();
                    }
                    within_word = false;
                    ++end;
                    begin = end;
                } else {
                    within_word = true;
                    ++end;
                }
            }
        }

        std::cout << "There are " << id_to_word.size() << " unique tokens in the vocabulary." << endl;
    }
};

} // namespace bpephrase
