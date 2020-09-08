#!/bin/bash
set -ex
# set -euo pipefail

# clean the states of transmission
# sudo rm -rf downloads/*
# sudo rm -rf config/*
# mkdir -p config downloads
#
sudo rm -rf ~/dev/pvn/utils/output/output_videos/*
sudo mkdir -p ~/dev/pvn/utils/output/output_videos/


# CONTAINER_NAME='faktory_srv'
#
# CID=$(docker ps -q -f status=running -f name=^/${CONTAINER_NAME}$)
#
# if [ ! "${CID}" ]; then
#     echo "Container doesn't exist"
# else
#     echo "Running!"
#     docker kill $(docker ps -q)
# fi
#
# unset CID



for a in `docker ps -a -q`
do
  echo "Stopping container - $a"
  docker stop $a
done
