#!/bin/bash

set -ex

sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
sudo apt install qbittorrent-nox -y

sudo adduser --system --group qbittorrent-nox
sudo adduser qbittorrent-nox qbittorrent-nox

sudo cp /etc/systemd/system/qbittorrent-nox.service /etc/systemd/system/qbittorrent-nox.service.backup
sudo wget https://raw.githubusercontent.com/Sonic3R/Scripts/master/bash_scripts/qbit.service -O /home/qbit.service

sudo cp /home/qbit.service /etc/systemd/system/qbittorrent-nox.service
sudo systemctl start qbittorrent-nox
sudo systemctl daemon-reload
sudo systemctl enable qbittorrent-nox

echo "url is :8088"


# seeder setup
#
# https://www.cyberciti.biz/faq/howto-create-lage-files-with-dd-command/
# https://superuser.com/questions/470949/how-do-i-create-a-1gb-random-file-in-linux
sudo rm -rf ~/data
mkdir -p ~/data
sudo setfacl -R -m "u:qbittorrent-nox:rwx" /home/data
mkdir -p ~/torrents
cd ~/data

# https://www.reddit.com/r/torrents/comments/8likab/how_to_create_a_trackerless_torrent_using_the_dht/
for i in {1..10}
do
	echo "Welcome $i times"
	sudo fallocate -l 1G p2p_image_${i}.img
	sudo dd if=/dev/random of=p2p_image_${i}.img bs=1 count=0 seek=1G
	stat p2p_image_${i}.img
done


echo "To create torrents and start seeding them, a qBitTorrent GUI must be used."
