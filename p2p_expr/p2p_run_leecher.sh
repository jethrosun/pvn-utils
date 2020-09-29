#!/bin/bash
set -ex

for (( c=1; c<=$1; c++ ))
do
	deluge-console -c ~/bt_data/config "add $HOME/dev/pvn/utils/workloads/torrent_files/p2p_image_${c}.img.torrent"
done

