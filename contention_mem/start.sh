#!/bin/bash

# we don't need to build every time
cd /home/${USER}/dev/pvn/utils/contention_mem/
# /home/jethros/.cargo/bin/cargo build --release

# sudo /home/jethros/.cargo/bin/cargo run $1 $2 $3

zero=0;
if [[ $1 -eq $zero ]]; then
  # echo "no memory contention";
  exit;
fi

sudo taskset -c 3 /home/${USER}/data/cargo-target/release/contention_mem $1 > $2

# until sudo nice --20 /home/jethros/data/cargo-target/release/contention_mem $1 > $2; do
#     echo "Server 'myserver' crashed with exit code $?.  Respawning.." >&2
#     sleep 1
# done
