#!/bin/bash
while ! /usr/local/bin/wait-for-it.sh 127.0.0.1:4000 --timeout=1; do
   sleep 1
done

/usr/local/bin/synthetic_srv $1 $2 $3 $4
