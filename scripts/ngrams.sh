ROOT=/n/rush_lab/data/iwslt14-de-en/data/iwslt14.tokenized.phrase.de-en

SRC_TRAIN=${ROOT}/train.de
TGT_TRAIN_MACHINE=${ROOT}/train.en.baseline2.out
TGT_TRAIN_NATURAL=${ROOT}/train.en
SRC_TRAIN_OUT=${ROOT}/train.phrase.de
TGT_TRAIN_OUT_MACHINE=${ROOT}/train.phrase.machine.en
TGT_TRAIN_OUT_NATURAL=${ROOT}/train.phrase.natural.en

SRC_VALID=${ROOT}/valid.de
TGT_VALID=${ROOT}/valid.en
SRC_VALID_OUT=${ROOT}/valid.phrase.de
TGT_VALID_OUT_MACHINE=${ROOT}/valid.phrase.machine.en
TGT_VALID_OUT_NATURAL=${ROOT}/valid.phrase.natural.en

SRC_TEST=${ROOT}/test.de
TGT_TEST=${ROOT}/test.en
SRC_TEST_OUT=${ROOT}/test.phrase.de
TGT_TEST_OUT_MACHINE=${ROOT}/test.phrase.machine.en
TGT_TEST_OUT_NATURAL=${ROOT}/test.phrase.natural.en

SRC_SAVE=${ROOT}/phrase.src.pkl
TGT_SAVE_MACHINE=${ROOT}/phrase.machine.tgt.pkl
TGT_SAVE_NATURAL=${ROOT}/phrase.natural.tgt.pkl

run_ngrams_src() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_TRAIN \
        --output $SRC_TRAIN_OUT \
        --save $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRC=$!
    wait $PIDSRC && echo "src train done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_VALID \
        --output $SRC_VALID_OUT \
        --load $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCVALID=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_TEST \
        --output $SRC_TEST_OUT \
        --load $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCTEST=$!
    wait $PIDSRCVALID && echo "src valid done!"
    wait $PIDSRCTEST && echo "src test done!"
}

run_ngrams_tgt_machine() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --output $TGT_TRAIN_OUT_MACHINE \
        --save $TGT_SAVE_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGT=$!
    wait $PIDTGT && echo "tgt train done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_VALID \
        --output $TGT_VALID_OUT_MACHINE \
        --load $TGT_SAVE_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTVALID && echo "tgt valid done!"
}

run_ngrams_tgt_natural() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_NATURAL \
        --output $TGT_TRAIN_OUT_NATURAL \
        --save $TGT_SAVE_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGT=$!
    wait $PIDTGT && echo "tgt train done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_VALID \
        --output $TGT_VALID_OUT_NATURAL \
        --load $TGT_SAVE_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTVALID && echo "tgt valid done!"
}
