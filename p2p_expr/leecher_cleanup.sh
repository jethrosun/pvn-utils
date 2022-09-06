#!/bin/bash
# https://www.reddit.com/r/freenas/comments/41gj0q/remove_completed_torrents_from_transmission/
# set -x
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


