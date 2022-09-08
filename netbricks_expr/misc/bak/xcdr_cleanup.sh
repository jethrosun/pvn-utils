#!/bin/bash
set -ex
# set -euo pipefail

# clean the states of transmission
# sudo rm -rf downloads/*
# sudo rm -rf config/*
# mkdir -p config downloads
#
sudo rm -rf /tmp/
sudo mkdir -p /tmp/
sudo chmod 1777 /tmp

sudo rm -rf ~/dev/pvn/utils/output/output_videos/
sudo mkdir -p ~/dev/pvn/utils/output/output_videos/
sudo rm -rf /data/output_videos/
sudo mkdir -p /data/output_videos/

for a in $(docker ps -a -q)
do
  echo "Stopping container - $a"
  docker stop "$a"
done
