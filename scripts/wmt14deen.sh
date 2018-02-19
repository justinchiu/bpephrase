ROOT=/n/rush_lab/data/wmt14-de-en
TEXT=${ROOT}/data/wmt14_en_de
DISTILL=${ROOT}/data/wmt14_en_de.distill
PHRASE=${ROOT}/data/wmt14_en_de.phrase

SRC_TRAIN=${TEXT}/train.de
SRC_TRAIN_OUT=${PHRASE}/train.phrase.de
SRC_TRAIN_REPEAT_OUT=${PHRASE}/train.phrase.repeat.de
# NOT YET DONE
TGT_TRAIN_MACHINE=${DISTILL}/train.en.baseline.brnn.out
TGT_TRAIN=${TEXT}/train.en
TGT_TRAIN_OUT=${PHRASE}/train.phrase.en
TGT_TRAIN_OUT_NODISTILL=${PHRASE}/train.phrase.nodistill.en

SRC_VALID=${TEXT}/valid.de
SRC_VALID_OUT=${PHRASE}/valid.phrase.de
SRC_VALID_REPEAT_OUT=${PHRASE}/valid.phrase.repeat.de
TGT_VALID=${TEXT}/valid.en
TGT_VALID_OUT=${PHRASE}/valid.phrase.en

SRC_TEST=${TEXT}/test.de
SRC_TEST_OUT=${PHRASE}/test.phrase.de
SRC_TEST_REPEAT_OUT=${PHRASE}/test.phrase.repeat.de
TGT_TEST=${TEXT}/test.en
TGT_TEST_OUT=${PHRASE}/test.phrase.en

SRC_SAVE=${ROOT}/phrase.src.pkl
TGT_SAVE=${ROOT}/phrase.tgt.pkl

dbg_ngrams_src() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_VALID \
        --fit $SRC_VALID \
        --save src.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_VALID \
        --output train.output.src.dbg \
        --load src.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_VALID \
        --output train.output.src.repeat.dbg \
        --load src.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 \
        --repeat-ngrams
}

dbg_ngrams_tgt() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --fit $TGT_TRAIN \
        --save tgt.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --output train.output.tgt.dbg \
        --load tgt.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10
}

run_ngrams_src() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_TRAIN \
        --fit $SRC_TRAIN \
        --save $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCGEN=$!
    wait $PIDSRCGEN && echo "src gen done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_TRAIN \
        --output $SRC_TRAIN_OUT \
        --load $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCTRAIN=$!
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
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_TRAIN \
        --output $SRC_TRAIN_REPEAT_OUT \
        --load $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --repeat-ngrams \
        --min-occurrence 10 & PIDSRCTRAINREPEAT=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_VALID \
        --output $SRC_VALID_REPEAT_OUT \
        --load $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --repeat-ngrams \
        --min-occurrence 10 & PIDSRCVALIDREPEAT=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $SRC_TEST \
        --output $SRC_TEST_REPEAT_OUT \
        --load $SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --repeat-ngrams \
        --min-occurrence 10 & PIDSRCTESTREPEAT=$!
    wait $PIDSRCTRAIN && echo "src train done!"
    wait $PIDSRCVALID && echo "src valid done!"
    wait $PIDSRCTEST && echo "src test done!"
    wait $PIDSRCTRAINREPEAT && echo "src train repeat done!"
    wait $PIDSRCVALIDREPEAT && echo "src valid repeat done!"
    wait $PIDSRCTESTREPEAT && echo "src test repeat done!"
}

run_ngrams_tgt() {
    echo "Running target ngrams"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --fit $TGT_TRAIN \
        --save $TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTGEN=$!
    wait $PIDTGTGEN && echo "tgt train done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --output $TGT_TRAIN_OUT \
        --load $TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAIN=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --output $TGT_TRAIN_OUT_NODISTILL \
        --load $TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAINNODISTILL=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_VALID \
        --output $TGT_VALID_OUT \
        --load $TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTTRAIN && echo "tgt train done!"
    wait $PIDTGTTRAINNODISTILL && echo "tgt train no distill done!"
    wait $PIDTGTVALID && echo "tgt valid done!"
}

