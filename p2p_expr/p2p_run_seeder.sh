#!/bin/bash
#set -x
set -euo pipefail

# Server string: "host:port --auth username:password"
SERVER="127.0.0.1:9091 --auth transmission:transmission"

# Get the final server string to use.
echo -n "Using hardcoded server string: "
echo "${SERVER: : 10}(...)"  # Truncate to not print auth.

# ----------------------------------
#   Check status of transmission
# ----------------------------------

for (( c=1; c<=10; c++ ))
do
	transmission-remote $SERVER -a /home/jethros/data/p2p_image_${c}.torrent
done
transmission-remote $SERVER -s

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
