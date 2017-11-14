
# Transform unigram corpus into ngram corpus
# Takes the top N ngrams for each n
# Greedily merges largest ngrams first
 
from collections import Counter
import dill as pickle
from typing import List, Tuple, Dict
import typing
from multiprocessing import Pool

import itertools

import numpy as np

from spans import get_parse, join_parse

Sen = List[str]
Corpus = List[Sen]
Key = Tuple[str, ...]

def args():
    import argparse
    parser = argparse.ArgumentParser(description="ngrams.py")
    parser.add_argument("-c", "--corpus", type=str, help="Source corpus.")
    parser.add_argument("-f", "--fit", type=str, help="Fit ngrams to this corpus. Required if constructing.")
    parser.add_argument("-o", "--output", type=str, help="Output corpus.")
    parser.add_argument("-n", "--ngram-orders", type=int, nargs="+", help="The n-gram orders.")
    parser.add_argument("-k", "--topks", type=int, nargs="+", help="The topk n-grams to be considered.")
    parser.add_argument("-m", "--min-occurrence", type=int, help="The minimum # of occurrences for an ngram.")
    parser.add_argument("-l", "--load", type=str, help="Pre-saved ngram path.")
    parser.add_argument("-s", "--save", type=str, help="Ngram save path.")
    return parser.parse_args()

def tokenize_corpus(path: str) -> Corpus:
    corpus = []
    with open(path, "r") as f:
        for line in f:
            corpus.append(line.strip().split())
    return corpus

class Ngrams():
    def __init__(self, ns: List[int], topks: List[int], min_occurrence: int) -> None:
        assert(len(ns) > 0)
        assert(len(topks) > 0)

        self.ns = ns
        self.topks = topks
        self.min_occurrence = 10
        self.ngrams: List[typing.Counter[Key]] = []

    def load_ngrams(self, path: str):
        with open(path, "rb") as f:
            # This should be a mapping from (n words) -> count
            self.ngrams = pickle.load(f)
        # Check if n is correct by only looking at first key
        for i, c in enumerate(self.ngrams):
            assert(len(c) == 0 or len(next(iter(c))) == self.ns[i])

    def dump_ngrams(self, path: str):
        with open(path, "wb") as f:
            pickle.dump(self.ngrams, f, pickle.HIGHEST_PROTOCOL)
        if self.unfiltered:
            with open(path + ".unfiltered", "wb") as f:
                pickle.dump(self.unfiltered, f, pickle.HIGHEST_PROTOCOL)
        if self.unfit_ngrams:
            with open(path + ".unfit", "wb") as f:
                pickle.dump(self.unfit_ngrams, f, pickle.HIGHEST_PROTOCOL)

    def construct_ngrams(self, corpus: Corpus):
        self.unfiltered = []
        for n, k in zip(self.ns, self.topks):
            c: typing.Counter[Key] = Counter()
            for sentence in corpus:
                for j in range(len(sentence) - n):
                    c[tuple(sentence[j:j+n])] += 1
            self.unfiltered.append(c)
            self.ngrams.append(Counter({k: v for k,v in c.most_common(k) if v > self.min_occurrence}))

    def fit(self, corpus: Corpus):
        # Filter ngrams from counter if they don't occur.
        # This needs to be called on 
        self.unfit_ngrams = self.ngrams
        nset = set()
        i = 0
        for sentence in transform_corpus_lol(self, corpus):
            for word in sentence:
                nset.add(tuple(word))
        self.ngrams = []
        for ngrams in self.unfit_ngrams:
            fit_set = nset & set(ngrams)
            self.ngrams.append(Counter({k: ngrams[k] for k in fit_set}))

def transform_corpus(ngrams: Ngrams, corpus: Corpus):
    pool = Pool(processes=8)
    def score(x):
        return 1 if any(map(lambda d: x in d, ngrams.ngrams)) else 0
 
    def f(sentence):
        return get_parse(sentence, ngrams.ns, score)

    return pool.map(f, corpus)

def transform_corpus_lol(ngrams: Ngrams, corpus: Corpus):
    def score(x):
        return 1 if any(map(lambda d: x in d, ngrams.ngrams)) else 0
 
    def f(sentence):
        return get_parse(sentence, ngrams.ns, score)

    return map(f, corpus)
 #       newCorpus: Corpus = []
 #       for sentence in corpus:
 #           newCorpus.append(
 #               get_parse(
 #                   sentence,
 #                   self.ns,
 #                   lambda x: 1 if any(map(lambda d: x in d, self.ngrams)) else 0
 #               )
 #           )
 #       return newCorpus

ns = []


if __name__ == "__main__":
    args = args()
    # ngram orders: [2,...,10]
    # topks = 10k * len(ngram_orders)
    # min_occ = 10
    if len(args.topks) == 1:
        topks = args.topks * len(args.ngram_orders)
    else:
        topks = args.topks
    ng = Ngrams(args.ngram_orders, topks, args.min_occurrence)

    traincorpus = tokenize_corpus(args.corpus)
    if args.load:
        ng.load_ngrams(args.load)
        with open(args.output, "w") as f:
            for sentence in transform_corpus_lol(ng, traincorpus):
                f.write(join_parse(sentence))
                f.write("\n")
    elif args.save and args.fit:
        ng.construct_ngrams(traincorpus)
        ng.fit(tokenize_corpus(args.fit))
        ng.dump_ngrams(args.save)
    else:
        print("HEY! EITHER LOAD OR SAVE.")

    #trainpath = "/n/rush_lab/data/iwslt14-de-en/data/iwslt14.tokenized.phrase.de-en/train.en"
    # Use this one!
    #trainpath = "/n/holylfs/LABS/rush_lab/data/iwslt14-de-en/data/iwslt14.tokenized.phrase.de-en/train.en.baseline2.out"
    #
    #phrasecorpus = transform_corpus(ng, traincorpus)
    # Use this!
    #outpath = "/n/holylfs/LABS/rush_lab/data/iwslt14-de-en/data/iwslt14.tokenized.phrase.de-en/train.en.baseline2.out.phrase"
    #for x in itertools.islice(phrasecorpus, 10):
    #    print(list(x))
