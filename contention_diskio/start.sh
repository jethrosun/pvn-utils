#!/bin/bash


zero=0;
if [[ $1 -eq $zero ]]; then
  # echo "no memory contention";
  exit;
fi

sudo taskset -c $2 /home/jethros/data/cargo-target/release/contention_diskio $1 > $3

