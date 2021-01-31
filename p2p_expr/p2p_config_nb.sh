#!/bin/bash
set -ex


sudo -u jethros mkdir -p /home/jethros/Downloads
sudo -u jethros mkdir -p /data/bt/config
sudo -u jethros mkdir -p /data/bt/deluge_data

#prep the output dirs
# if [ ! -e ~/bt_data/Complete ]; then
#     mkdir -p ~/bt_data/Complete
#     mkdir -p ~/bt_data/Torrents
#     mkdir -p ~/bt_data/InProgress
#     mkdir -p ~/bt_data/Drop
# fi

# check if config exists in /config and set it up if not
if [ ! -e /data/bt/config/auth ]; then
	#create a default user (apart from admin/sudo -u jethros deluge)
	#echo "user:Password1:10" >> /config/auth

	#daemon must be running to setup
	sudo -u jethros deluged -c /data/bt/config

	#need a small delay here or the first config setting fails
	sleep 1

	#enable report connections (for webui to connect to backend)
	sudo -u jethros deluge-console -c /data/bt/config "config -s allow_remote True"
	#view it with: sudo -u jethros deluge-console -c /config "config allow_remote"

	#setup the paths (broken due to a str decode bug)

	sudo -u jethros deluge-console -c /data/bt/config "config -s move_completed_path /data/bt/deluge_data/Complete"
	sudo -u jethros deluge-console -c /data/bt/config "config -s torrentfiles_location /data/bt/deluge_data/Torrents"
	sudo -u jethros deluge-console -c /data/bt/config "config -s download_location /data/bt/deluge_data/InProgress"
	sudo -u jethros deluge-console -c /data/bt/config "config -s autoadd_location /data/bt/deluge_data/Drop"

	#daemon port which the WEB ui connects to
	#sudo -u jethros deluge-console -c ~/bt_data/config "config -s daemon_port 58846"

	#sudo -u jethros deluge-console -c ~/bt_data/config "config -s upnp False"
	#sudo -u jethros deluge-console -c ~/bt_data/config "config -s compact_allocation False"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s add_paused False"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s move_completed True"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s copy_torrent_file True"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s autoadd_enable True"

	sudo -u jethros deluge-console -c /data/bt/config 'config -s dht false'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s utpex false'

	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_limit 10'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_downloading 10'

	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_seeding 10'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_download_speed_per_torrent 5000'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_upload_speed_per_torrent 5000'
	# sudo -u jethros deluge-console -c /home/jethros/bt_data/config 'config -s max_seed_speed_per_torrent 2500'

	sudo -u jethros deluge-console -c /data/bt/config "halt"
fi

echo "Starting up now ..."
sudo -u jethros nice deluged -c /data/bt/config
# sudo -u jethros deluge-web -c ~/bt_data/config
