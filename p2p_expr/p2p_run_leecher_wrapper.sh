#!/bin/bash
set -ex

sleep 10

if [ $1 == "1" ]; then
	setup=1
elif [ $1 == "2" ]; then
	setup=2
elif [ $1 == "3" ]; then
	setup=4
elif [ $1 == "4" ]; then
	setup=6
elif [ $1 == "5" ]; then
	setup=8
elif [ $1 == "6" ]; then
	setup=10
else
	printf "Unknown setup: %s" $1
fi


for (( c=1; c<=setup; c++ ))
do
	echo $c
	deluge-console -c /home/jethros/bt_data/config "add /home/jethros/dev/pvn/utils/workloads/torrent_files/p2p_image_${c}.img.torrent"
done
