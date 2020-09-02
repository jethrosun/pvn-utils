#!/bin/bash
#set -x
set -euo pipefail

SERVER="127.0.0.1:9091 --auth transmission:transmission"

# Get the final server string to use.
echo -n "Using hardcoded server string: "
echo "${SERVER: : 10}(...)"  # Truncate to not print auth.

# ----------------------------------
#   Add torrent jobs
# ----------------------------------

for (( c=1; c<=$1; c++ ))
do
	transmission-remote $SERVER -a ~/dev/pvn/utils/workloads/torrent_files/p2p_image_${c}.torrent
done

transmission-remote $SERVER -s

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote $SERVER --session-info
# List statistical information from the server
transmission-remote $SERVER --session-stats
# List all torrents
transmission-remote $SERVER --list
