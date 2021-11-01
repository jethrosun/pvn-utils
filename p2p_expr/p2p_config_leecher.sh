#!/bin/bash
set -ex

mkdir -p /home/jethros/bt_data/config
mkdir -p /home/jethros/Downloads

# to properly config deluge, see 
#
# 	https://dev.deluge-torrent.org/wiki/UserGuide/BandwidthTweaking
if [ ! -e /home/jethros/bt_data/config/auth ]; then
	deluged -c /home/jethros/bt_data/config
	sleep 1
	deluge-console -c /home/jethros/bt_data/config "config -s allow_remote True"

	#deluge-console -c ~/bt_data/config "config -s daemon_port 58846"
	#deluge-console -c ~/bt_data/config "config -s upnp False"
	# deluge-console -c ~/bt_data/config "config -s add_paused False"
	# deluge-console -c ~/bt_data/config "config -s move_completed True"
	# deluge-console -c ~/bt_data/config "config -s copy_torrent_file True"
	# deluge-console -c ~/bt_data/config "config -s autoadd_enable True"

	deluge-console -c /home/jethros/bt_data/config 'config -s dht false'
	deluge-console -c /home/jethros/bt_data/config 'config -s utpex false'
	# deluge-console -c /home/jethros/bt_data/config 'config -s cache_size 0'
	# deluge-console -c /home/jethros/bt_data/config "config -s compact_allocation True"

	deluge-console -c /home/jethros/bt_data/config 'config -s max_active_limit 10'
	deluge-console -c /home/jethros/bt_data/config 'config -s max_active_downloading 10'
	deluge-console -c /home/jethros/bt_data/config 'config -s max_active_seeding 10'

	# KiB per second? 54000 and 5400
	deluge-console -c /home/jethros/bt_data/config 'config -s max_download_speed_per_torrent 10000'
	deluge-console -c /home/jethros/bt_data/config 'config -s max_upload_speed_per_torrent 10000'
	deluge-console -c /home/jethros/bt_data/config 'config -s max_seed_speed_per_torrent 10000'

	deluge-console -c /home/jethros/bt_data/config "config -s seed_time_limit 2400"
	deluge-console -c /home/jethros/bt_data/config "config -s max_download_speed 100000"
	deluge-console -c /home/jethros/bt_data/config "config -s max_upload_speed 100000"

	deluge-console -c /home/jethros/bt_data/config "halt"
fi

echo "Starting up now ..."
nice deluged -c /home/jethros/bt_data/config
# deluge-web -c ~/bt_data/config
