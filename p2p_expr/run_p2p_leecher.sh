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

echo $1
for i in {1..$1}
do
	transmission-remote $SERVER -a ~/dev/pvn/utils/workloads/torrent_files/p2p_image_${i}.img
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
