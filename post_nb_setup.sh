#!/bin/bash
set -ex

sudo $HOME/dev/netbricks/scripts/bind-xl710.sh

cd $HOME/dev/pvn/utils
git pull
sudo $HOME/dev/pvn/utils/cleanup.sh
$HOME/dev/pvn/utils/setup.sh
printf "PVN utils updated"
