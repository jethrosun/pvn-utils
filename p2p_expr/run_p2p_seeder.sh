#!/bin/bash
#set -x
set -euo pipefail

# Server string: "host:port --auth username:password"
SERVER="127.0.0.1:9091 --auth transmission:transmission"

# Get the final server string to use.
echo -n "Using hardcoded server string: "
echo "${SERVER: : 10}(...)"  # Truncate to not print auth.

transmission-daemon -c ~/data

# ----------------------------------
#   Check status of transmission
# ----------------------------------

# List session information from the server
transmission-remote $SERVER --session-info
# List statistical information from the server
transmission-remote $SERVER --session-stats
# List all torrents
transmission-remote $SERVER --list
