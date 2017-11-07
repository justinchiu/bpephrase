
from copy import deepcopy
from typing import List
from collections import Counter
import numpy as np

def brute_force(seq, n, value_fn):
    # Convenience function for brute force enumeration of parses.
    return max(enumerative(seq, n, value_fn), key=lambda x: x[1])

def enumerative(seq, n, value_fn):
    # Generate all possible parses.
    if len(seq) < n:
        yield ([], 0)
    for i in range(len(seq)-n+1):
        chunk = [tuple(seq[i:i+n])]
        chunk_val= value_fn(chunk[0])
        for tail, tail_val in enumerative(seq[i+n:], n, value_fn):
            yield (chunk + tail, chunk_val + tail_val)

def best_spans(seq, n, value_fn):
    debug = False
    # Simple DP for getting the best spans while ignorning spans that
    # have a value of 0.
    history = np.zeros((n, 2))
    backpointers = np.empty((n, 2), dtype=object)
    for i in range(n):
        backpointers[i,0] = []
        backpointers[i,1] = []

    i = 0
    while i < len(seq)-n+1:
        chunk = tuple(seq[i:i+n])
        chunk_val = value_fn(chunk)

        head = history[0]
        overlap = history[1:]
        overlap_flat_idx = overlap.argmax()
        overlap_idx = np.unravel_index(overlap_flat_idx, overlap.shape)

        # Do backpointers first before mutating scores.
        if chunk_val > 0:
            backpointers[0,0] = \
                backpointers[0,0] + [chunk] if head[0] > head[1] \
                else backpointers[0,1] + [chunk]
        else:
            # We do not want to add chunks that have value 0
            backpointers[0,0] = \
                backpointers[0,0] if head[0] > head[1] \
                else backpointers[0,1]
        if backpointers[1:][overlap_idx]:
            backpointers[0,1] = backpointers[1:][overlap_idx]

        history[0,0] = head.max() + chunk_val
        history[0,1] = overlap.max()

        # Barrel shift to simulate circular array.
        backpointers = np.roll(backpointers, -1, 0)
        history = np.roll(history, -1, 0)
        i += 1

    idx = history[-1].argmax()
    return backpointers[-1, idx], history[-1, idx] 

def get_remainder(seq, spans):
    # Return a list of disjoint segments of the original sequence
    # that are not 
    new_sentences = []
    sentence = []
    spans = deepcopy(spans)
    i = 0
    j = 0
    while i < len(seq):
        word = seq[i]
        if not spans:
            new_sentences.append(seq[i:])
            break
        elif spans[0][0] != word:
            sentence.append(word)
            i += 1
        elif spans[0][0] == word:
            if sentence:
                new_sentences.append(sentence)
                sentence = []
            i += len(spans[0])
            spans.pop(0)
    if sentence:
        new_sentences.append(sentence)
    return new_sentences

def concatmap(f, xs):
    acc = []
    for x in xs:
        acc.extend(f(x))
    return acc

def gen_flatten(xs):
    if not isinstance(xs, (list, tuple)):
        yield xs
    else:
        for x in xs:
            if isinstance(x, (list,tuple)):
                for y in gen_flatten(x):
                    yield y
            else:
                yield x

def get_parse(seq, ns, value_fn):
    all_spans = []
    indices = list(range(len(seq)))
    value_fn_idxs = lambda idxs: value_fn(tuple(map(lambda x: seq[x], idxs)))
    remainder = [indices]
    for n in sorted(ns, reverse=True):
        spans = concatmap(lambda x: best_spans(x, n, value_fn_idxs)[0], remainder)
        all_spans.extend(spans)
        all_spans.sort(key=lambda x: x[0])
        remainder = get_remainder(indices, all_spans)
    unigrams = map(lambda x: (x,), gen_flatten(remainder))
    all_spans.extend(unigrams)
    all_spans.sort(key=lambda x:x[0])
    return map(lambda x: map(lambda idx: seq[idx], x), all_spans)

def join_parse(parse):
    return " ".join(map(lambda x: "_".join(x), parse))

if __name__ == "__main__":
    print("Testing stuff")
    n = 3
    seq = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
           "o", "p", "q", "r", "s", "t", "u", "v"]

    value_fn = Counter({
        (seq[0], seq[1], seq[2]): 1,
        (seq[2], seq[3], seq[4]): 2,
        (seq[4], seq[5], seq[6]): 10,
        (seq[6], seq[7], seq[8]): 3,
        (seq[15], seq[16], seq[17]): 3,
    })
    for i in range(len(seq)-1):
        value_fn[(seq[i], seq[i+1])] += 1

    #print(brute_force(seq, n, lambda x: 1))
    #print(brute_force(seq, n, lambda x: value_fn[x]))

    #print(best_spans(seq, n, lambda x: 1))
    #print(best_spans(seq, n, lambda x: value_fn[x]))
    #spans = best_spans(seq, n, lambda x: value_fn[x])
    #remainder = get_remainder(seq, spans[0])
    #print(concatmap(lambda x: [x], [1,2,3,4,5]))
    #ok = concatmap(lambda x: best_spans(x, n-1, lambda x: 1)[0], remainder)
    #print(spans[0] + ok)
    #lol = get_remainder(seq, sorted(spans[0] + ok, key=lambda x: x[0]))
    #print(lol)
    #parse = get_parse(seq, [2,3], lambda x: value_fn[x])
    #print(parse)
    parse = get_parse(seq, [2,3], lambda x: 1 if x in value_fn else 0)
    print(join_parse(parse))
