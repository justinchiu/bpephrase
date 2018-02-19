WMT_ROOT=/n/rush_lab/data/wmt14-de-en
WMT_TEXT=${WMT_ROOT}/data/wmt14_en_de
WMT_PHRASE_DIR=${WMT_ROOT}/phrasedata
WMT_DISTILL=${WMT_PHRASE_DIR}/wmt14_en_de.distill
WMT_PHRASE=${WMT_PHRASE_DIR}/wmt14_en_de.phrase

WMT_SRC_TRAIN=${WMT_TEXT}/train.de
WMT_SRC_TRAIN_OUT=${WMT_PHRASE}/train.phrase.de
WMT_SRC_TRAIN_REPEAT_OUT=${WMT_PHRASE}/train.phrase.repeat.de
# NOT YET DONE
WMT_TGT_TRAIN_MACHINE=${WMT_DISTILL}/train.en.baseline.brnn.out
WMT_TGT_TRAIN=${WMT_TEXT}/train.en
WMT_TGT_TRAIN_OUT=${WMT_PHRASE}/train.phrase.en
WMT_TGT_TRAIN_OUT_NODISTILL=${WMT_PHRASE}/train.phrase.nodistill.en

WMT_SRC_VALID=${WMT_TEXT}/valid.de
WMT_SRC_VALID_OUT=${WMT_PHRASE}/valid.phrase.de
WMT_SRC_VALID_REPEAT_OUT=${WMT_PHRASE}/valid.phrase.repeat.de
WMT_TGT_VALID=${WMT_TEXT}/valid.en
WMT_TGT_VALID_OUT=${WMT_PHRASE}/valid.phrase.en

WMT_SRC_TEST=${WMT_TEXT}/test.de
WMT_SRC_TEST_OUT=${WMT_PHRASE}/test.phrase.de
WMT_SRC_TEST_REPEAT_OUT=${WMT_PHRASE}/test.phrase.repeat.de
WMT_TGT_TEST=${WMT_TEXT}/test.en
WMT_TGT_TEST_OUT=${WMT_PHRASE}/test.phrase.en

WMT_SRC_SAVE=${WMT_PHRASE_DIR}/phrase.src.pkl
WMT_TGT_SAVE=${WMT_PHRASE_DIR}/phrase.tgt.pkl

dbg_wmt_ngrams_src() {
    time python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_VALID \
        --fit $WMT_SRC_VALID \
        --save src.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10
    time python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_VALID \
        --output train.output.src.dbg \
        --load src.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10
    time python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_VALID \
        --output train.output.src.repeat.dbg \
        --load src.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 \
        --repeat-ngrams
}

dbg_wmt_ngrams_tgt() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_TGT_TRAIN \
        --fit $WMT_TGT_TRAIN \
        --save tgt.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_TGT_TRAIN_MACHINE \
        --output train.output.tgt.dbg \
        --load tgt.save.dbg \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10
}

run_wmt_ngrams_src() {
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_TRAIN \
        --fit $WMT_SRC_TRAIN \
        --save $WMT_SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCGEN=$!
    wait $PIDSRCGEN && echo "src gen done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_TRAIN \
        --output $WMT_SRC_TRAIN_OUT \
        --load $WMT_SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCTRAIN=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_VALID \
        --output $WMT_SRC_VALID_OUT \
        --load $WMT_SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCVALID=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_TEST \
        --output $WMT_SRC_TEST_OUT \
        --load $WMT_SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDSRCTEST=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_TRAIN \
        --output $WMT_SRC_TRAIN_REPEAT_OUT \
        --load $WMT_SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --repeat-ngrams \
        --min-occurrence 10 & PIDSRCTRAINREPEAT=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_VALID \
        --output $WMT_SRC_VALID_REPEAT_OUT \
        --load $WMT_SRC_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --repeat-ngrams \
        --min-occurrence 10 & PIDSRCVALIDREPEAT=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_SRC_TEST \
        --output $WMT_SRC_TEST_REPEAT_OUT \
        --load $WMT_SRC_SAVE \
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

run_wmt_ngrams_tgt() {
    echo "Running target ngrams"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_TGT_TRAIN \
        --fit $WMT_TGT_TRAIN \
        --save $WMT_TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTGEN=$!
    wait $PIDTGTGEN && echo "tgt train done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_TGT_TRAIN \
        --output $WMT_TGT_TRAIN_OUT \
        --load $WMT_TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAIN=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_TGT_TRAIN \
        --output $WMT_TGT_TRAIN_OUT_NODISTILL \
        --load $WMT_TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAINNODISTILL=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $WMT_TGT_VALID \
        --output $WMT_TGT_VALID_OUT \
        --load $WMT_TGT_SAVE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTTRAIN && echo "tgt train done!"
    wait $PIDTGTTRAINNODISTILL && echo "tgt train no distill done!"
    wait $PIDTGTVALID && echo "tgt valid done!"
}

