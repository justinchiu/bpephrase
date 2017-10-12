#include "bpephrase/dictionary.h"

#include <iostream>

namespace bpephrase {

char endl = '\n';
bool debug = false;

const std::string Dictionary::BOS = "<s>";
const std::string Dictionary::EOS = "</s>";
const std::string Dictionary::UNK = "<unk>";
const std::string Dictionary::PAD = "<pad>";

int Dictionary::addWord(const std::string& token) {
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

int Dictionary::lookupWord(const std::string& token) {
    auto it = word_to_id.find(token);
    return it == word_to_id.end() ? unk : it->second;
}

void Dictionary::initializeVocabulary() {
    word_to_id.clear();
    id_to_word.clear();

    bos = addWord(BOS);
    eos = addWord(EOS);
    unk = addWord(UNK);
    pad = addWord(PAD);
}

void Dictionary::tokenizeText(std::string filename, Corpus & corpus) {
    std::ifstream ifs(filename);
    corpus.clear();
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
        sentence.reserve(32);
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
                    corpus.emplace_back(std::move(sentence));
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

}
