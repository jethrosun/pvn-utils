#!/bin/bash
set -ex

sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
sudo apt install qbittorrent qbittorrent-nox -y

sudo rm -rf ~/data
mkdir -p ~/data
