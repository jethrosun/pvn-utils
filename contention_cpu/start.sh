#!/bin/bash

# we don't need to build every time
cd /home/jethros/dev/pvn/utils/contention_cpu/
# /home/jethros/.cargo/bin/cargo build --release

# sudo /home/jethros/.cargo/bin/cargo run $1 $2 $3

zero=0;
if [[ $1 -eq $zero ]]; then
  echo "no cpu contention";
  exit;
fi
sudo /home/jethros/data/cargo-target/release/contention_cpu $1 > $5
