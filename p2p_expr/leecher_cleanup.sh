#!/bin/bash
# set -x

# for a in $(docker ps -a -q)
# do
#   echo "Stopping container - $a"
#   docker stop "$a"
# done


sudo rm -rf /home/jethros/data/downloads
sudo mkdir -p /home/jethros/data/downloads
sudo chown -R jethros:jethros /home/jethros/data/downloads
sudo chmod -R 775 /home/jethros/data/downloads
