#!/bin/bash
set -ex

# seeder setup
# d8:announce35:http://10.200.111.125:9000/announce
# SERVER="--private --tracker http://10.200.111.125:9091/announce"

# https://www.cyberciti.biz/faq/howto-create-lage-files-with-dd-command/
# https://superuser.com/questions/470949/how-do-i-create-a-1gb-random-file-in-linux
sudo rm -rf ~/data
mkdir -p ~/data
mkdir -p ~/torrents
cd ~/data

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
		stat p2p_core_${core}_image_${i}.img

		transmission-create -o ~/torrents/p2p_core_${core}_image_${i}.torrent --private --tracker http://10.200.111.125:9091/announce p2p_core_${core}_image_${i}.img
		# cp p2p_core_${core}_image_${i}.img.torrent ~/torrents
		chmod 644 ~/torrents/p2p_core_${core}_image_${i}.torrent

		# start seed
		# transmisson-remote --add ~/torrents/p2p_core_${core}_image_${i}.img.torrent
		# Download
		# exec /snap/bin/aria2c --seed-ratio=0.0 -V -d . p2p_core_${core}_image_${i}.img.torrent
	done
done


# echo "To create torrents and start seeding them, a qBitTorrent GUI must be used."
