#!/bin/bash
set -ex
# set -euo pipefail


sudo rm -rf /tmp/
sudo mkdir -p /tmp/
sudo chmod 1777 /tmp

sudo rm -rf /data/tmp/profile
sudo rm -rf /home/jethros/data/profile
sudo -u jethros mkdir -p /data/tmp/profile
sudo -u jethros mkdir -p /home/jethros/data/profile
