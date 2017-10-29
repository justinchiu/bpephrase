
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

def best_span(seq, n, value_fn):
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
        if backpointers[1:][overlap_idx]:
            backpointers[0,1] = backpointers[1:][overlap_idx]

        history[0,0] = head.max() + chunk_val
        history[0,1] = overlap.max()

        # Barrel shift to simulate circular array.
        backpointers = np.roll(backpointers, -1, 0)
        history = np.roll(history, -1, 0)
        i += 1

    return history, backpointers

def get_remainder(seq, spans):
    # Return a list of disjoint segments of the original sequence
    # that are not 
    new_sentences = []
    sentence = []
    spans = deepcopy(spans)
    i = 0
    while i < len(seq):
        word = seq[i]
        if spans[0] != word:
            sentence.append(word)
            i += 1
        else sentence:
            new_sentences.append(sentence)
            sentence = []
            i += len(spans[0])
            spans.pop(0)
    return new_sentences


if __name__ == "__main__":
    print("Testing stuff")
    n = 3
    seq = list(range(9))

    value_fn = Counter({
        (0,1,2): 1,
        (2,3,4): 2,
        (4,5,6): 10,
        (6,7,8): 3,
    })

    print(brute_force(seq, n, lambda x: 1))
    print(brute_force(seq, n, lambda x: value_fn[x]))

    print(best_span(seq, n, lambda x: 1))
    print(best_span(seq, n, lambda x: value_fn[x]))

