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

# rm dir
sudo rm -rf /data/downloads/*

sudo rm -rf /data/config/*
sudo mkdir -p /data/config /data/downloads

sudo usermod -a -g debian-transmission jethros
sudo chgrp debian-transmission /data/downloads
sudo chmod 770 /data/downloads



# Server string: "host:port --auth username:password"
SERVER="127.0.0.1:9091 --auth transmission:mypassword"

# Which torrent states should be removed at 100% progress.
DONE_STATES=("Seeding" "Stopped" "Finished" "Idle")

# Get the final server string to use.
if [[ -n "$TRANSMISSION_SERVER" ]]; then
    echo -n "Using server string from the environment: "
    SERVER="$TRANSMISSION_SERVER"
elif [[ "$#" -gt 0 ]]; then
    echo -n "Using server string passed through parameters: "
    SERVER="$*"
else
    echo -n "Using hardcoded server string: "
fi
echo "${SERVER: : 10}(...)"  # Truncate to not print auth.

# Use transmission-remote to get the torrent list from transmission-remote.
TORRENT_LIST=$(transmission-remote $SERVER --list | sed -e '1d' -e '$d' | awk '{print $1}' | sed -e 's/[^0-9]*//g')

# Iterate through the torrents.
for TORRENT_ID in $TORRENT_LIST
do
    INFO=$(transmission-remote $SERVER --torrent "$TORRENT_ID" --info)
    echo -e "Processing #$TORRENT_ID: \"$(echo "$INFO" | sed -n 's/.*Name: \(.*\)/\1/p')\"..."
    # To see the full torrent info, uncomment the following line.
    # echo "$INFO"
    PROGRESS=$(echo "$INFO" | sed -n 's/.*Percent Done: \(.*\)%.*/\1/p')
    STATE=$(echo "$INFO" | sed -n 's/.*State: \(.*\)/\1/p')

    echo "Torrent #$TORRENT_ID is $PROGRESS% done with state \"$STATE\". Delete anyway."
    transmission-remote $SERVER --torrent "$TORRENT_ID" --remove-and-delete
done

# service restart
sudo service transmission-daemon stop
sudo service transmission-daemon start

sudo pkill -HUP transmission-da
# stop and restart daemon
sudo /etc/init.d/transmission-daemon stop
sudo /etc/init.d/transmission-daemon start

# -------------------------------
#   operations we want to enable
# -------------------------------

# Set the session's maximum memory cache size in MiB. This cache is used to reduce disk IO.
transmission-remote $SERVER --cache=0
# Disable upload speed limits. If current torrent(s) are selected this operates on them. Otherwise, it changes the global setting.
transmission-remote $SERVER --no-uplimit
# Disable download speed limits. If current torrent(s) are selected this operates on them. Otherwise, it changes the global setting.
transmission-remote $SERVER --no-downlimit
# Disable uTP for peer connections. If current torrent(s) are selected this operates on them. Otherwise, it changes the global setting.
transmission-remote $SERVER --no-utp
# Use directory as the default location for newly added torrents to download files to.
transmission-remote $SERVER --download-dir=/data/downloads

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote $SERVER --session-info
# List statistical information from the server
transmission-remote $SERVER --session-stats
# List all torrents
transmission-remote $SERVER --list
