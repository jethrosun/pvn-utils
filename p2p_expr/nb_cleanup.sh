#!/bin/bash
set -ex

torrentlist=`transmission-remote --list | sed -e '1d;$d;s/^ *//' | cut -f1 -d' '`

for torrentid in $torrentlist
do
	torrentid=`echo "$torrentid" | sed 's:*::'`
	info=`transmission-remote --torrent $torrentid --info`

	name=`echo "$info" | grep "name: *"`
	dl_completed=`echo "$info" | grep "percent done: 100%"`
	state_stopped=`echo "$info" | grep "state: stopped\|finished\|idle"`

	echo "torrent $torrentid is in $state_stopped"
	echo "$name"
	# echo "moving downloaded file(s) to $movedir"
	# transmission-remote --torrent $torrentid --move $movedir
	echo "removing torrent from list"
	transmission-remote --torrent $torrentid --remove
done


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

sudo rm -rf /data/downloads
sudo mkdir -p /data/downloads
sudo chown -R debian-transmission:debian-transmission /data/downloads
sudo chmod -R 775 /data/downloads

