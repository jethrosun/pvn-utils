#!/bin/bash
set -ex

sudo rm -rf /data/bt
sudo rm -rf /data/tmp
sudo rm -rf /data/tmp3
sudo rm -rf /data/tmp4
sudo rm -rf /home/jethros/Downloads

sudo -u jethros mkdir -p /data/bt
sudo -u jethros mkdir -p /data/tmp/profile
sudo -u jethros mkdir -p /data/tmp3
sudo -u jethros mkdir -p /data/tmp4
sudo -u jethros mkdir -p /home/jethros/Downloads


sudo rm -rf /home/jethros/torrents
sudo -u jethros mkdir -p /home/jethros/torrents

# scp torrents
sudo -u jethros scp -r jethros@10.200.111.125:~/torrents/* /home/jethros/torrents


sudo rm -rf /data/downloads
for core_id in {1..5}
do
	sudo -u jethros mkdir -p /data/downloads/core_${core_id}
	sudo -u jethros chmod 777 /data/downloads/core_${core_id}
done
# sudo chown -R debian-transmission:debian-transmission /data/downloads
sudo chmod -R 777 /data/downloads


# cd /home/jethros/dev/pvn/p2p-builder
# sudo -u jethros make net
