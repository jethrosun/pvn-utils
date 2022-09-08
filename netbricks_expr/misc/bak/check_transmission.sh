#!/bin/bash
set -ex

# NOTE:
#   Certain changes can't be done from tranmission remote and has to go through
#   the config file. Parameters we need to change are:
#
#   utp-enabled:
#   cache-size-mb:
#   download-queue-enabled
#
# Config setting file:
# https://github.com/transmission/transmission/wiki/Editing-Configuration-Files
#
# Man page:
# https://manpages.debian.org/testing/transmission-cli/transmission-remote.1.en.html

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


# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote $SERVER --session-info

# List statistical information from the server
transmission-remote $SERVER --session-stats

# List all torrents
transmission-remote $SERVER --list


# TODO
# --torrent-done-script filename
# Specify a file to run each time a torrent finishes
