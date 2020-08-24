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
#   Debugging
# ----------------------------------

# Where to store transmission's log messages.
transmission-remote $SERVER --logfile=/home/jethros/transmission.log
# Show error messages
transmission-remote $SERVER --log-error
# Show error and info messages
transmission-remote $SERVER --log-info
transmission-remote $SERVER --log-debug
# Show error, info, and debug messages

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
