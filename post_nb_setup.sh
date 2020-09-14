#!/bin/bash
set -ex

cd $HOME/dev/pvn/utils
git pull
sudo $HOME/dev/pvn/utils/cleanup.sh
$HOME/dev/pvn/utils/setup.sh

sudo $HOME/dev/netbricks/scripts/bind-xl710.sh
printf "PVN utils updated\n"
