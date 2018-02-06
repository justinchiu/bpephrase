ROOT=/n/rush_lab/data/iwslt14-de-en/data/iwslt14.tokenized.phrase.de-en

SRC_TRAIN=${ROOT}/train.de
SRC_TRAIN_OUT=${ROOT}/train.phrase.de
SRC_TRAIN_REPEAT_OUT=${ROOT}/train.phrase.repeat.de
TGT_TRAIN=${ROOT}/train.en
#TGT_TRAIN_MACHINE=${ROOT}/train.en.baseline3.out
# Use bidirectional encoder later
TGT_TRAIN_MACHINE=${ROOT}/train.en.baseline.brnn.out
TGT_TRAIN_OUT_MACHINE_NATURAL=${ROOT}/train.phrase.machine.natural.en
TGT_TRAIN_OUT_NATURAL_MACHINE=${ROOT}/train.phrase.natural.machine.en
TGT_TRAIN_OUT_MACHINE_MACHINE=${ROOT}/train.phrase.machine.machine.en
TGT_TRAIN_OUT_NATURAL_NATURAL=${ROOT}/train.phrase.natural.natural.en
TGT_TRAIN_OUT_MACHINE_NATURAL_NODISTILL=${ROOT}/train.phrase.machine.natural.nodistill.en
TGT_TRAIN_OUT_NATURAL_MACHINE_NODISTILL=${ROOT}/train.phrase.natural.machine.nodistill.en
TGT_TRAIN_OUT_MACHINE_MACHINE_NODISTILL=${ROOT}/train.phrase.machine.machine.nodistill.en
TGT_TRAIN_OUT_NATURAL_NATURAL_NODISTILL=${ROOT}/train.phrase.natural.natural.nodistill.en

SRC_VALID=${ROOT}/valid.de
SRC_VALID_OUT=${ROOT}/valid.phrase.de
SRC_VALID_REPEAT_OUT=${ROOT}/valid.phrase.repeat.de
TGT_VALID=${ROOT}/valid.en
TGT_VALID_OUT_MACHINE_NATURAL=${ROOT}/valid.phrase.machine.natural.en
TGT_VALID_OUT_NATURAL_NATURAL=${ROOT}/valid.phrase.natural.natural.en
TGT_VALID_OUT_MACHINE_MACHINE=${ROOT}/valid.phrase.machine.machine.en
TGT_VALID_OUT_NATURAL_MACHINE=${ROOT}/valid.phrase.natural.machine.en

SRC_TEST=${ROOT}/test.de
SRC_TEST_OUT=${ROOT}/test.phrase.de
SRC_TEST_REPEAT_OUT=${ROOT}/test.phrase.repeat.de
TGT_TEST=${ROOT}/test.en
TGT_TEST_OUT_MACHINE_NATURAL=${ROOT}/test.phrase.machine.natural.en
TGT_TEST_OUT_NATURAL_NATURAL=${ROOT}/test.phrase.natural.natural.en
TGT_TEST_OUT_MACHINE_MACHINE=${ROOT}/test.phrase.machine.machine.en
TGT_TEST_OUT_NATURAL_MACHINE=${ROOT}/test.phrase.natural.machine.en

SRC_SAVE=${ROOT}/phrase.src.pkl
TGT_SAVE_MACHINE_NATURAL=${ROOT}/phrase.machine.natural.tgt.pkl
TGT_SAVE_NATURAL_NATURAL=${ROOT}/phrase.natural.natural.tgt.pkl
TGT_SAVE_MACHINE_MACHINE=${ROOT}/phrase.machine.machine.tgt.pkl
TGT_SAVE_NATURAL_MACHINE=${ROOT}/phrase.natural.machine.tgt.pkl

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

run_ngrams_src_old() {
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
    wait $PIDSRCTRAIN && echo "src train done!"
    wait $PIDSRCVALID && echo "src valid done!"
    wait $PIDSRCTEST && echo "src test done!"
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

run_ngrams_tgt_machine_natural() {
    echo "Ngramming machine and fitting to natural"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --fit $TGT_TRAIN \
        --save $TGT_SAVE_MACHINE_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTGEN=$!
    wait $PIDTGTGEN && echo "tgt train done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --output $TGT_TRAIN_OUT_MACHINE_NATURAL \
        --load $TGT_SAVE_MACHINE_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAIN=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --output $TGT_TRAIN_OUT_MACHINE_NATURAL_NODISTILL \
        --load $TGT_SAVE_MACHINE_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAINNODISTILL=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_VALID \
        --output $TGT_VALID_OUT_MACHINE_NATURAL \
        --load $TGT_SAVE_MACHINE_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTTRAIN && echo "tgt train done!"
    wait $PIDTGTTRAINNODISTILL && echo "tgt train no distill done!"
    wait $PIDTGTVALID && echo "tgt valid done!"
}

run_ngrams_tgt_natural_natural() {
    echo "Ngramming natural and fitting to natural"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --fit $TGT_TRAIN \
        --save $TGT_SAVE_NATURAL_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTGEN=$!
    wait $PIDTGTGEN && echo "tgt gen done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --output $TGT_TRAIN_OUT_NATURAL_NATURAL \
        --load $TGT_SAVE_NATURAL_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAIN=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --output $TGT_TRAIN_OUT_NATURAL_NATURAL_NODISTILL \
        --load $TGT_SAVE_NATURAL_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAINNODISTILL=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_VALID \
        --output $TGT_VALID_OUT_NATURAL_NATURAL \
        --load $TGT_SAVE_NATURAL_NATURAL \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTTRAIN && echo "tgt train done!"
    wait $PIDTGTTRAINNODISTILL && echo "tgt train no distill done!"
    wait $PIDTGTVALID && echo "tgt valid done!"
}

run_ngrams_tgt_machine_machine() {
    echo "Ngramming machine and fitting to machine"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --fit $TGT_TRAIN_MACHINE \
        --save $TGT_SAVE_MACHINE_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTGEN=$!
    wait $PIDTGTGEN && echo "tgt train done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --output $TGT_TRAIN_OUT_MACHINE_MACHINE \
        --load $TGT_SAVE_MACHINE_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAIN=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --output $TGT_TRAIN_OUT_MACHINE_MACHINE_NODISTILL \
        --load $TGT_SAVE_MACHINE_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAINNODISTILL=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_VALID \
        --output $TGT_VALID_OUT_MACHINE_MACHINE \
        --load $TGT_SAVE_MACHINE_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTTRAIN && echo "tgt train done!"
    wait $PIDTGTTRAINNODISTILL && echo "tgt train no distill done!"
    wait $PIDTGTVALID && echo "tgt valid done!"
}

run_ngrams_tgt_natural_machine() {
    echo "Ngramming natural and fitting to machine"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --fit $TGT_TRAIN_MACHINE \
        --save $TGT_SAVE_NATURAL_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTGEN=$!
    wait $PIDTGTGEN && echo "tgt gen done!"
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN_MACHINE \
        --output $TGT_TRAIN_OUT_NATURAL_MACHINE \
        --load $TGT_SAVE_NATURAL_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAIN=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_TRAIN \
        --output $TGT_TRAIN_OUT_NATURAL_MACHINE_NODISTILL \
        --load $TGT_SAVE_NATURAL_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTTRAINNODISTILL=$!
    python /n/home13/jchiu/projects/bpephrase/python/ngrams.py \
        --corpus $TGT_VALID \
        --output $TGT_VALID_OUT_NATURAL_MACHINE \
        --load $TGT_SAVE_NATURAL_MACHINE \
        --ngram-orders 2 3 4 5 6 7 8 9 10 \
        --topks 10000 \
        --min-occurrence 10 & PIDTGTVALID=$!
    wait $PIDTGTTRAIN && echo "tgt train done!"
    wait $PIDTGTTRAINNODISTILL && echo "tgt train no distill done!"
    wait $PIDTGTVALID && echo "tgt valid done!"
}
