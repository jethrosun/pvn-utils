#!/bin/bash
set -ex

printf "Getting netbricks "
mkdir -p ~/dev
rm -rf ~/dev/netbricks
git clone git@github.com:jethrosun/NetBricks.git -b expr ~/dev/netbricks
~/dev/netbricks/build.sh
printf "netbricks building done"

sudo ~/dev/netbricks/scripts/bind-xl710.sh

# cd ~/dev/netbricks/scripts/tuning
# sudo ./energy.sh

cd ~/dev/pvn/utils
git pull
sudo ~/dev/pvn/utils/cleanup.sh
~/dev/pvn/utils/setup.sh
printf "pvn utils done"
