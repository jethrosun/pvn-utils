#!/bin/bash

# Clears finished downloads from Transmission.
# Version: 1.1
#
# Newest version can always be found at:
# https://gist.github.com/pawelszydlo/e2e1fc424f2c9d306f3a
#
# Server string is resolved in this order:
# 1. TRANSMISSION_SERVER environment variable
# 2. Parameters passed to this script
# 3. Hardcoded string in this script (see below).

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


# TODO: figure out hte number of torrent jobs i am running

# Use transmission-remote to get the torrent list from transmission-remote.
DONE_LIST=$(transmission-remote $SERVER --list  | awk '{print $5}' )
UNKNOWN_LIST=$(transmission-remote $SERVER --list  | awk '{print $4}' )
total_count=0
count=0

# Iterate through the torrents.
for VAL in $DONE_LIST
do
	total_count=$((total_count+1))
	if [[ $VAL == "Done" ]]; then
		count=$((count+1))
	fi
done
# taking care of unknown ones
for VAL in $UNKNOWN_LIST
do
	if [[ $VAL == "Unknown" ]]; then
		count=$((count+1))
	fi
done

# hack
count=$((count+2))

if [[ $count == $total_count ]]; then
	echo "P2P jobs all finished!!"
else
	echo "Count is #$count, total number of torrent jobs is #$total_count"
fi
