#!/bin/bash
set -ex


mkdir -p ~/bt_data
mkdir -p ~/Downloads

#prep the output dirs
if [ ! -e ~/bt_data/Complete ]; then
	mkdir -p ~/bt_data/Complete
	mkdir -p ~/bt_data/Torrents
	mkdir -p ~/bt_data/InProgress
	mkdir -p ~/bt_data/Drop
fi

mkdir ~/bt_data/config

# check if config exists in /config and set it up if not
if [ ! -e ~/bt_data/config/auth ]; then
	#create a default user (apart from admin/deluge)
	#echo "user:Password1:10" >> /config/auth

	#daemon must be running to setup
	deluged -c ~/bt_data/config

	#need a small delay here or the first config setting fails
	sleep 1

	#enable report connections (for webui to connect to backend)
	deluge-console -c ~/bt_data/config "config -s allow_remote True"
	#view it with: deluge-console -c /config "config allow_remote"

	#setup the paths (broken due to a str decode bug)

	# deluge-console -c ~/bt_data/config "config -s move_completed_path /home/jethros/bt_data/Complete"
	# deluge-console -c ~/bt_data/config "config -s torrentfiles_location /home/jethros/bt_data/Torrents"
	# deluge-console -c ~/bt_data/config "config -s download_location /home/jethros/bt_data/InProgress"
	# deluge-console -c ~/bt_data/config "config -s autoadd_location /home/jethros/bt_data/Drop"

	#daemon port which the WEB ui connects to
	deluge-console -c ~/bt_data/config "config -s daemon_port 58846"

	deluge-console -c ~/bt_data/config "config -s upnp False"
	#deluge-console -c ~/bt_data/config "config -s compact_allocation False"
	# deluge-console -c ~/bt_data/config "config -s add_paused False"
	# deluge-console -c ~/bt_data/config "config -s move_completed True"
	# deluge-console -c ~/bt_data/config "config -s copy_torrent_file True"
	# deluge-console -c ~/bt_data/config "config -s autoadd_enable True"

	#BT port:
	deluge-console -c ~/bt_data/config "config -s listen_ports (58332, 58333)"
	#default is (6881, 6891)
	deluge-console -c ~/bt_data/config "config -s random_port False"

    deluge-console -c ~/bt_data/config 'config -s max_upload_speed 1500'
    deluge-console -c ~/bt_data/config 'config -s max_download_speed 1500'

	deluge-console -c ~/bt_data/config "halt"
fi

echo "Starting up now ..."
deluged -c ~/bt_data/config
deluge-web -c ~/bt_data/config
