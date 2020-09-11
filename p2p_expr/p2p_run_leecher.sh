#!/bin/bash
set -ex

TORRENTS=" "

for (( c=1; c<=$1; c++ ))
do
	TORRENTS+=" img${c}_secret.torrent"
done

echo $TORRENTS

cd $HOME/dev/pvn/utils/workloads/torrent_files
qbittorrent-nox --profile=/home/jethros/data $TORRENTS &
