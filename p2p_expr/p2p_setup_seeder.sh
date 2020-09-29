#!/bin/bash

set -ex


echo "url is :8088"


# seeder setup
#
# https://www.cyberciti.biz/faq/howto-create-lage-files-with-dd-command/
# https://superuser.com/questions/470949/how-do-i-create-a-1gb-random-file-in-linux
sudo rm -rf ~/data
mkdir -p ~/data
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
