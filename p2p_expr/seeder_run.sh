#!/bin/bash
set -exuo pipefail

# https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
# http://aria2.github.io/manual/en/html/aria2c.html

# aria2c --seed-ratio=0.0 --listen-port=9000 --bt-enable-lpd --bt-external-ip=10.200.111.125 --enable-peer-exchange -V -d . ~/torrents/*.torrent

# echo "To create torrents and start seeding them, a qBitTorrent GUI must be used."

for core in {1..5}
do
        echo "Core $core "
	for i in {0..12}
	do
		transmission-remote --add ~/torrents/p2p_core_${core}_image_${i}.torrent --verify --start
                # transmission-remote --torrent=/home/jethros/data/p2p_core_${core}_image_${i}.torrent \
                #         -a p2p_core_${core}_image_${i}.torrent --verify \
                #         --download-dir=/home/jethros/data --start
	done
done
#
# # transmission-daemon -c ~/data
# # ----------------------------------
# #   Check status of transmission
# # ----------------------------------
#
# # List session information from the server
# transmission-remote  --session-info
# # List statistical information from the server
# transmission-remote  --session-stats
# # List all torrents
# transmission-remote  --list
