#!/bin/bash

echo "$@"
# https://unix.stackexchange.com/questions/190027/top-bn1-not-giving-correct-cpu-usage
top -b -n2 | awk '/^top -/ { p=!p } { if (!p) print }'| grep "$@" | awk '{ SUM += $9} END { print SUM }'
# ps -eo size,command --sort -size | grep "$@"| awk '{ hr=$1/1024 ; sum +=hr} END {print sum}'

if [ $? -ne 0 ]; then
  echo No processes with the specified name\(s\) were found
fi
