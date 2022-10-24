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
