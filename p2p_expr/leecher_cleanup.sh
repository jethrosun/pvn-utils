#!/bin/bash
# https://www.reddit.com/r/freenas/comments/41gj0q/remove_completed_torrents_from_transmission/
# set -x

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


sudo rm -rf /home/jethros/data/downloads
sudo mkdir -p /home/jethros/data/downloads
sudo chown -R debian-transmission:debian-transmission /home/jethros/data/downloads
sudo chmod -R 775 /home/jethros/data/downloads

