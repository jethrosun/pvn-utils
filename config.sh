#!/bin/bash
set -ex

printf "Getting netbricks "
mkdir -p $HOME/dev
rm -rf $HOME/dev/netbricks
git clone git@github.com:jethrosun/NetBricks.git -b expr $HOME/dev/netbricks
$HOME/dev/netbricks/build.sh
printf "netbricks building done"

sudo $HOME/dev/netbricks/scripts/bind-xl710.sh

# cd ~/dev/netbricks/scripts/tuning
# sudo ./energy.sh

cd $HOME/dev/pvn/utils
git pull
sudo $HOME/dev/pvn/utils/cleanup.sh
$HOME/dev/pvn/utils/setup.sh
printf "pvn utils done"
