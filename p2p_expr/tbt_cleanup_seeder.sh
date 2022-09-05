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

# -------------------------------
#   operations we want to enable
# -------------------------------

# Disable uTP for peer connections. If current torrent(s) are selected this operates on them. Otherwise, it changes the global setting.
transmission-remote --no-utp
# Use directory as the default location for newly added torrents to download files to.
transmission-remote --download-dir=/home/jethros/qbt_data/downloads

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote --session-info
# List statistical information from the server
transmission-remote  --session-stats
# List all torrents
transmission-remote --list
