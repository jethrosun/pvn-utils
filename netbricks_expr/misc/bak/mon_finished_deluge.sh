#!/bin/bash

echo "second"
sudo -u jethros taskset -c 5 deluge-console -c /data/bt/config 'info'
