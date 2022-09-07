#!/bin/bash
set -ex

sudo rm -rf /data/bt
sudo rm -rf /data/output_videos
mkdir -p /data/bt

rm -rf ~/data ~/torrents
mkdir -p ~/data/downloads
mkdir -p ~/data/Downloads
mkdir -p ~/torrents

# scp torrents
scp -r jethros@10.200.111.125:~/torrents/* ~/torrents

