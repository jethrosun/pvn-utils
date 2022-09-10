#!/bin/bash
set -ex

sudo rm -rf /data/bt
sudo rm -rf /data/tmp
sudo rm -rf /data/tmp3
sudo rm -rf /data/tmp4

sudo -u jethros mkdir -p /data/bt
sudo -u jethros mkdir -p /data/tmp/profile
sudo -u jethros mkdir -p /data/tmp3
sudo -u jethros mkdir -p /data/tmp4


sudo rm -rf /data/downloads
for core_id in {1..5}
do
	sudo mkdir -p /data/downloads/core_${core_id}
done
sudo chown -R debian-transmission:debian-transmission /data/downloads
sudo chmod -R 775 /data/downloads

