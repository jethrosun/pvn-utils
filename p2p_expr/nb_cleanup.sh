#!/bin/bash
set -ex


sudo rm -rf /data/bt
sudo rm -rf /data/tmp
sudo rm -rf /data/tmp3
sudo rm -rf /data/tmp4
sudo rm -rf /home/jethros/Downloads

sudo -u jethros mkdir -p /data/bt
sudo -u jethros mkdir -p /data/tmp/profile
sudo -u jethros mkdir -p /data/tmp3
sudo -u jethros mkdir -p /data/tmp4
sudo -u jethros mkdir -p /home/jethros/Downloads

