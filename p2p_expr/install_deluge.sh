#!/bin/bash
set -ex

sudo add-apt-repository ppa:deluge-team/stable -y
sudo apt-get update -y
sudo apt-get install deluge -y

 sudo apt-get install deluged deluge-web deluge-console -y

