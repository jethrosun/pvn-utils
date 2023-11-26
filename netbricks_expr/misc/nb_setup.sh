#!/bin/bash
set -ex

sudo rm -rf /data/bt
sudo rm -rf /data/tmp
sudo rm -rf /data/tmp3
sudo rm -rf /data/tmp4
sudo rm -rf /home/${USER}/Downloads

sudo -u ${USER} mkdir -p /data/bt
sudo -u ${USER} mkdir -p /data/tmp/profile
sudo -u ${USER} mkdir -p /data/tmp3
sudo -u ${USER} mkdir -p /data/tmp4
sudo -u ${USER} mkdir -p /home/${USER}/Downloads


sudo rm -rf /home/${USER}/torrents
sudo -u ${USER} mkdir -p /home/${USER}/torrents

# scp torrents
sudo -u ${USER} scp -r ${USER}@10.200.111.125:~/torrents/* /home/${USER}/torrents


sudo rm -rf /data/downloads
for core_id in {1..5}
do
	sudo -u ${USER} mkdir -p /data/downloads/core_${core_id}
	# sudo -u ${USER} chmod 777 /data/downloads/core_${core_id}
done
# sudo chown -R debian-transmission:debian-transmission /data/downloads
# sudo chmod -R 777 /data/downloads


# cd /home/${USER}/dev/pvn/p2p-builder
# sudo -u ${USER} make net
