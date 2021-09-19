#!/bin/bash

# we don't need to build every time
cd /home/jethros/dev/pvn/utils/contention_diskio/
# /home/jethros/.cargo/bin/cargo build --release

# sudo /home/jethros/.cargo/bin/cargo run $1 $2 $3

sudo /home/jethros/data/cargo-target/release/contention_diskio $1 > $5
