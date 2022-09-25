#!/bin/bash

cd /home/jethros/dev/pvn/utils/contention_cpu/

zero=0;
if [[ $1 -eq $zero ]]; then
  # echo "no cpu contention";
  exit;
fi

sudo /home/jethros/data/cargo-target/release/contention_cpu $1 $2 > $3
