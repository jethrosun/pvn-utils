#!/bin/bash


zero=0;
if [[ $1 -eq $zero ]]; then
  # echo "no memory contention";
  exit;
fi

sudo taskset -c $2 /home/${USER}/data/cargo-target/release/contention_diskio $1 $2 $3 > $4

