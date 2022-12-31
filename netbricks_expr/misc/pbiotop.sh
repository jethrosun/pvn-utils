#!/bin/bash

echo "$@"
/usr/bin/python3 /usr/share/bcc/tools/biotop -C -p $@

if [ $? -ne 0 ]; then
  echo No processes with the specified name\(s\) were found
fi
