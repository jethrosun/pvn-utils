#!/bin/bash
set -ex

for a in $(docker ps -a -q)
do
    echo "Stopping container - $a"
    docker stop "$a"
done

sudo rm -rf /data/downloads
for core_id in {1..5}
do
    sudo -u jethros mkdir -p /data/downloads/core_${core_id}
    # sudo -u jethros chmod 777 /data/downloads/core_${core_id}
done

