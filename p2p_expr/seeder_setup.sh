#!/bin/bash
set -e

# sudo iptables -I INPUT -p tcp --dport 9000 -j ACCEPT
# sudo ufw allow out 9000/tcp

# https://www.cyberciti.biz/faq/howto-create-lage-files-with-dd-command/
# https://superuser.com/questions/470949/how-do-i-create-a-1gb-random-file-in-linux
rm -rf ~/data
rm -rf ~/torrents
mkdir -p ~/data/downloads
mkdir -p ~/data/Downloads
mkdir -p ~/torrents

cd ~/data/downloads
# the max number is 13 for now, so it is 5 cores * 13 images
# https://www.reddit.com/r/torrents/comments/8likab/how_to_create_a_trackerless_torrent_using_the_dht/
for core in {1..5}
do
	echo "Core $core "
	for i in {0..12}
	do
		echo "Making $i images"
		sudo fallocate -l 1G p2p_core_${core}_image_${i}.img
		sudo dd if=/dev/random of=p2p_core_${core}_image_${i}.img bs=1 count=0 seek=1G

		# stat p2p_core_${core}_image_${i}.img
		sudo chmod 644 p2p_core_${core}_image_${i}.img

		# make torrents
		# transmission-create -o ~/torrents/p2p_core_${core}_image_${i}.torrent --private --tracker http://10.200.111.125:9000/announce p2p_core_${core}_image_${i}.img
		mktorrent -v -p -a http://10.200.111.125:9000/announce -o ~/torrents/p2p_core_${core}_image_${i}.torrent p2p_core_${core}_image_${i}.img

		# cp p2p_core_${core}_image_${i}.img.torrent ~/torrents
		chmod 644 ~/torrents/p2p_core_${core}_image_${i}.torrent

	done
done

sudo chown -R jethros:jethros .

