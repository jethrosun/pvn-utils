#!/bin/bash
#set -x
set -euo pipefail

TORRENTLIST=`transmission-remote --list | sed -e '1d;$d;s/^ *//' | cut -f1 -d' '`

for TORRENTID in $TORRENTLIST
do
	TORRENTID=`echo "$TORRENTID" | sed 's:*::'`
	INFO=`transmission-remote --torrent $TORRENTID --info`

	NAME=`echo "$INFO" | grep "Name: *"`
	DL_COMPLETED=`echo "$INFO" | grep "Percent Done: 100%"`
	STATE_STOPPED=`echo "$INFO" | grep "State: Stopped\|Finished\|Idle"`

	echo "Torrent $TORRENTID is in $STATE_STOPPED"
	echo "$NAME"
	# echo "Moving downloaded file(s) to $MOVEDIR"
	# transmission-remote --torrent $TORRENTID --move $MOVEDIR
	echo "Removing torrent from list"
	transmission-remote --torrent $TORRENTID --remove
done

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote --session-info
# List statistical information from the server
transmission-remote  --session-stats
# List all torrents
transmission-remote --list



service restart
sudo service transmission-daemon stop
sudo service transmission-daemon start

sudo pkill -HUP transmission-da
sudo /etc/init.d/transmission-daemon stop
sudo /etc/init.d/transmission-daemon start
