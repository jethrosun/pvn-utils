#!/bin/bash
# https://superuser.com/questions/1416328/check-total-usage-of-physical-memory-and-cpu-for-a-program-on-linux
# https://unix.stackexchange.com/questions/199315/in-linux-top-command-is-there-any-way-to-keep-track-of-values/199322

echo "$@"
top -b -d 1 -n 1 | grep "$@" | awk '{ SUM += $10} END { print SUM }'
# ps -eo size,command --sort -size | grep "$@"| awk '{ hr=$1/1024 ; sum +=hr} END {print sum}'

if [ $? -ne 0 ]; then
  echo No processes with the specified name\(s\) were found
fi
