#!/bin/bash

# https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
set -exuo pipefail


for core in {1..5}
do
        echo "Core $core "
	for i in {0..12}
	do
		transmisson-remote --add ~/torrents/p2p_core_${core}_image_${i}.torrent
                # transmission-remote --torrent=/home/jethros/data/p2p_core_${core}_image_${i}.torrent \
                #         -a p2p_core_${core}_image_${i}.torrent --verify \
                #         --download-dir=/home/jethros/data --start
	done
done

transmission-daemon -c ~/data

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote  --session-info
# List statistical information from the server
transmission-remote  --session-stats
# List all torrents
transmission-remote  --list
