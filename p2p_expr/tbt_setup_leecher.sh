#!/bin/bash
set -ex

sudo rm -rf ~/data ~/torrents
mkdir -p ~/data/downloads
mkdir -p ~/data/Downloads
mkdir -p ~/torrents

# scp torrents
scp -r jethros@10.200.111.125:~/torrents/* ~/torrents
