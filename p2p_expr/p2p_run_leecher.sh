#!/bin/bash
set -ex

TORRENTS=" "

for (( c=1; c<=$1; c++ ))
do
	TORRENTS+=" $HOME/dev/pvn/utils/workloads/torrent_files/img${c}_secret.torrent"
done

echo $TORRENTS

qbittorrent-nox --profile=/home/jethros/data $TORRENTS
