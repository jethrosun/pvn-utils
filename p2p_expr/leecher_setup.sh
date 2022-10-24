#!/bin/bash
set -ex

# for a in $(docker ps -a -q)
# do
#   echo "Stopping container - $a"
#   docker stop "$a"
# done


rm -rf ~/data ~/torrents
mkdir -p ~/data/downloads
mkdir -p ~/data/Downloads
mkdir -p ~/torrents

# scp torrents
scp -r jethros@10.200.111.125:~/torrents/* ~/torrents

cd ~/dev/pvn/p2p-builder
git checkout leecher


# make net
