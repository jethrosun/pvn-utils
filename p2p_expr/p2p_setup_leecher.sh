#!/bin/bash
set -ex

sudo add-apt-repository ppa:deluge-team/stable -y
sudo apt-get update -y
sudo apt-get install deluge -y

 sudo apt-get install deluged deluge-web deluge-console -y


sudo rm -rf ~/qbt_data
mkdir -p ~/qbt_data

echo "move all the deluge systemd file to where they belong"
sudo cp systemd_files/deluged.service       /etc/systemd/system/deluged.service
sudo cp systemd_files/deluge-web.service    /etc/systemd/system/deluge-web.service
# sudo cp systemd_files/deluged_user.conf
# sudo cp systemd_files/deluge_web_user.conf

sudo systemctl enable /etc/systemd/system/deluged.service
sudo systemctl start deluged
sudo systemctl status deluged

sudo systemctl enable /etc/systemd/system/deluge-web.service
sudo systemctl start deluge-web
sudo systemctl status deluge-web

sudo systemctl daemon-reload
sudo systemctl restart deluged
sudo systemctl restart deluge-web
