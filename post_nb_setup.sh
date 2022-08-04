#!/bin/bash
set -x

cd "$HOME/dev/pvn/utils" || exit
git pull

"$HOME/dev/pvn/utils/setup.sh"

sudo "$HOME/dev/pvn/utils/cleanup.sh"

sudo "$HOME/dev/netbricks/scripts/bind-xl710.sh"

printf "PVN utils updated\n"
