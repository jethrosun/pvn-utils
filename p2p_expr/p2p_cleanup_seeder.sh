#!/bin/bash
#set -x
set -euo pipefail

# service restart
sudo service transmission-daemon stop
sudo service transmission-daemon start

sudo pkill -HUP transmission-da
# stop and restart daemon
sudo /etc/init.d/transmission-daemon stop
sudo /etc/init.d/transmission-daemon start

sleep 5

# Server string: "host:port --auth username:password"
SERVER="127.0.0.1:9091 --auth transmission:transmission"

# Get the final server string to use.
echo -n "Using hardcoded server string: "
echo "${SERVER: : 10}(...)"  # Truncate to not print auth.

# -------------------------------
#   operations we want to enable
# -------------------------------

# Disable uTP for peer connections. If current torrent(s) are selected this operates on them. Otherwise, it changes the global setting.
transmission-remote $SERVER --no-utp
# Use directory as the default location for newly added torrents to download files to.
transmission-remote $SERVER --download-dir=/home/jethros/qbt_data/downloads

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote $SERVER --session-info
# List statistical information from the server
transmission-remote $SERVER --session-stats
# List all torrents
transmission-remote $SERVER --list
