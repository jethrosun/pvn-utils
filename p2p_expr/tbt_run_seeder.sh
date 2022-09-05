#!/bin/bash

# https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
set -euo pipefail


# Server string: "host:port --auth username:password"
# SERVER="127.0.0.1:9091 --auth transmission:transmission"
SERVER="--private --tracker http://10.200.111.125:8080/announce"

# Get the final server string to use.
echo -n "Using hardcoded server string: "
# echo "${SERVER: : 10}(...)"  # Truncate to not print auth.
echo "${SERVER: : 10}(...)"  # Truncate to not print auth.

# ----------------------------------
#   Check status of transmission
# ----------------------------------

for core in {1..5}
do
        echo "Core $core "
	for i in {0..12}
	do
                transmission-remote --torrent=/home/jethros/data/p2p_core_${core}_image_${c}.torrent \
                        -a p2p_image_${c}.torrent --verify \
                        --download-dir=/home/jethros/data --start
	done
done

# transmission-daemon -c ~/data

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote $SERVER --session-info
# List statistical information from the server
transmission-remote $SERVER --session-stats
# List all torrents
transmission-remote $SERVER --list
