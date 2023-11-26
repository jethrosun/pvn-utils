#!/bin/bash
set -ex


sudo rm -rf /tmp/
sudo mkdir -p /tmp/
sudo chmod 1777 /tmp

sudo rm -rf /data/tmp/profile
sudo rm -rf /home/${USER}/data/profile
sudo -u ${USER} mkdir -p /data/tmp/profile
sudo -u ${USER} mkdir -p /home/${USER}/data/profile
