#!/bin/bash
# set -x

# for a in $(docker ps -a -q)
# do
#   echo "Stopping container - $a"
#   docker stop "$a"
# done

BT_PID=`ps -eaf | grep deluged | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi

sudo rm -rf /home/jethros/data/downloads
sudo mkdir -p /home/jethros/data/downloads
sudo chown -R jethros:jethros /home/jethros/data/downloads
sudo chmod -R 775 /home/jethros/data/downloads


sudo rm -rf /home/jethros/bt_data/
sudo mkdir -p /home/jethros/bt_data/config
sudo chown -R jethros:jethros /home/jethros/bt_data
sudo chmod -R 775 /home/jethros/bt_data


sudo -u jethros deluged -c /home/jethros/bt_data/config
sudo -u jethros deluge-console -c /home/jethros/bt_data/config halt

sudo -u jethro cp /home/jethros/dev/pvn/p2p-builder/scripts/core.conf /home/jethros/bt_data/config/core.conf
