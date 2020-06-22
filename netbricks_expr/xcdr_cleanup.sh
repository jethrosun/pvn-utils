#!/bin/bash
#set -x
set -euo pipefail

# clean the states of transmission
# sudo rm -rf downloads/*
# sudo rm -rf config/*
# mkdir -p config downloads
#
sudo rm -rf ~/dev/pvn-utils/output/output_videos/*
sudo mkdir -p ~/dev/pvn-utils/output/output_videos/


if [ $(docker ps | grep keyword | wc -l) -gt 0 ]
then
    echo "Running!"
	docker kill $(docker ps -q)
else
    echo "Not running!"
    exit 1
fi
