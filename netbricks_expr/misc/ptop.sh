#!/bin/sh

echo "$@"
for i in `ps aux | egrep "$@" | awk '{print $2}'| uniq`; do  top -b -n 2 -d 0.2 -p $i  | tail -1 | awk '{print $9}'; done

if [ $? -ne 0 ]; then
  echo No processes with the specified name\(s\) were found
fi
