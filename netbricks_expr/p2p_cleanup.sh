#!/bin/bash
#set -x
set -euo pipefail

# clean the states of transmission
# sudo rm -rf downloads/*
# sudo rm -rf config/*
# mkdir -p config downloads
#
sudo rm -rf /data/downloads/*
sudo rm -rf /data/config/*
sudo mkdir -p /data/config /data/downloads
