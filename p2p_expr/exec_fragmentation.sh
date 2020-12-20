#!/bin/bash

# TOTAL_NUM_OF_FILES=100
TOTAL_NUM_OF_FILES=1887436
RATIO=15
target="fragmented_files"

start=`date +%s`


mkdir -p $target
rm -rf $target
mkdir -p $target

NUM_FILES_TO_DETELE=$(($TOTAL_NUM_OF_FILES * $RATIO / 100))

for N in $(seq 1 $TOTAL_NUM_OF_FILES); do
	head -c 1M </dev/urandom >$target/$N
done;
echo "Created all of the files!"

for N in $(shuf -i 1-$TOTAL_NUM_OF_FILES -n $NUM_FILES_TO_DETELE | sort -n); do
	rm $target/$N
done;

end=`date +%s`

runtime=$((end-start))
echo "Total time is $runtime"
