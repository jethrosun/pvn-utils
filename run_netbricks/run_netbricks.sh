#!/bin/bash

set -euo pipefail

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
NF_NAME=pvn-tlsv-re
echo $NF_NAME
echo $@


$NETBRICKS_BUILD run $@ -f config_6core.toml
