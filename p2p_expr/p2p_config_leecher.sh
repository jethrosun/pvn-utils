#!/bin/bash
set -ex


mkdir -p /home/jethros/bt_data/config
mkdir -p /home/jethros/Downloads

#prep the output dirs
# if [ ! -e ~/bt_data/Complete ]; then
#     mkdir -p ~/bt_data/Complete
#     mkdir -p ~/bt_data/Torrents
#     mkdir -p ~/bt_data/InProgress
#     mkdir -p ~/bt_data/Drop
# fi

# check if config exists in /config and set it up if not
if [ ! -e /home/jethros/bt_data/config/auth ]; then
	#create a default user (apart from admin/deluge)
	#echo "user:Password1:10" >> /config/auth

	#daemon must be running to setup
	deluged -c /home/jethros/bt_data/config

	#need a small delay here or the first config setting fails
	sleep 1

	#enable report connections (for webui to connect to backend)
	deluge-console -c /home/jethros/bt_data/config "config -s allow_remote True"
	#view it with: deluge-console -c /config "config allow_remote"

	#setup the paths (broken due to a str decode bug)

	# deluge-console -c ~/bt_data/config "config -s move_completed_path /home/jethros/bt_data/Complete"
	# deluge-console -c ~/bt_data/config "config -s torrentfiles_location /home/jethros/bt_data/Torrents"
	# deluge-console -c ~/bt_data/config "config -s download_location /home/jethros/bt_data/InProgress"
	# deluge-console -c ~/bt_data/config "config -s autoadd_location /home/jethros/bt_data/Drop"

	#daemon port which the WEB ui connects to
	#deluge-console -c ~/bt_data/config "config -s daemon_port 58846"

	#deluge-console -c ~/bt_data/config "config -s upnp False"
	#deluge-console -c ~/bt_data/config "config -s compact_allocation False"
	# deluge-console -c ~/bt_data/config "config -s add_paused False"
	# deluge-console -c ~/bt_data/config "config -s move_completed True"
	# deluge-console -c ~/bt_data/config "config -s copy_torrent_file True"
	# deluge-console -c ~/bt_data/config "config -s autoadd_enable True"

	deluge-console -c /home/jethros/bt_data/config 'config -s max_active_limit 10'
	deluge-console -c /home/jethros/bt_data/config 'config -s max_active_downloading 10'

	deluge-console -c /home/jethros/bt_data/config 'config -s max_active_seeding 10'
	deluge-console -c /home/jethros/bt_data/config 'config -s max_download_speed_per_torrent 2000'
	deluge-console -c /home/jethros/bt_data/config 'config -s max_upload_speed_per_torrent 2000'
	# deluge-console -c /home/jethros/bt_data/config 'config -s max_seed_speed_per_torrent 2500'

	deluge-console -c /home/jethros/bt_data/config "halt"
fi

echo "Starting up now ..."
nice deluged -c /home/jethros/bt_data/config
# deluge-web -c ~/bt_data/config
