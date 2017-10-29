
# Transform unigram corpus into ngram corpus
# Takes the top N ngrams for each n
# Greedily merges largest ngrams first
 
from collections import Counter
import pickle
from typing import List, Tuple, Dict
import typing

import numpy as np

from spans import best_span

Sen = List[str]
Corpus = List[Sen]
Key = Tuple[str, ...]

def args():
    import argparse
    parser = argparse.ArgumentParser(description="ngrams.py")
    parser.add_argument("-t", "--train", type=str, help="Training corpus.")
    parser.add_argument("-n", "--ngram-orders", type=int, nargs="+", help="The n-gram orders.")
    parser.add_argument("-k", "--topks", type=int, nargs="+", help="The topk n-grams to be considered.")
    parser.add_argument("-l", "--load", type=str, help="Pre-saved ngram path.")
    return parser.parse_args()

def tokenize_corpus(path: str) -> Corpus:
    corpus = []
    with open(path, "r") as f:
        for line in f:
            corpus.append(line.strip().split())
    return corpus

class Ngrams():
    def __init__(self, ns: List[int], topks: List[int]) -> None:
        assert(len(ns) > 0)
        assert(len(topks) > 0)

        self.ns = ns
        self.topks = topks
        self.ngrams: List[typing.Counter[Key]] = []

    def load_ngrams(self, path):
        with open(path, "rb") as f:
            # This should be a mapping from (n words) -> count
            self.ngrams = pickle.load(f)
        # Check if n is correct by only looking at first key
        for i, c in enumerate(self.ngrams):
            assert(len(next(iter(c))) == self.ns[i])

    def dump_ngrams(self, path: str):
        with open(path, "wb") as f:
            pickle.dump(self.ngrams, f, pickle.HIGHEST_PROTOCOL)

    def construct_ngrams(self, corpus: Corpus):
        for (i, (n, k)) in enumerate(zip(self.ns, self.topks)):
            c: typing.Counter[Key] = Counter()
            for sentence in corpus:
                for i in range(len(sentence) - n):
                    c[tuple(sentence[i:i+n])] += 1
            self.ngrams[i] = Counter(dict(c.most_common(k)))

    def transform_corpus(self, corpus: Corpus):
        newCorpus: Corpus = []
        for sentence in corpus:
            history, backpointers = best_span(sentence)
            newCorpus.append(sentence)


if __name__ == "__main__":
    args = args()
    Ngrams([2,3,4,5], [10000] * 4)

    trainpath = "/n/rush_lab/data/iwslt14-de-en/data/iwslt14.tokenized.phrase.de-en/train.en"
