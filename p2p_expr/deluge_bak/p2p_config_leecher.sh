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
	deluge-console -c /home/jethros/bt_data/config 'config -s dht false'
	deluge-console -c /home/jethros/bt_data/config 'config -s utpex false'
	deluge-console -c /home/jethros/bt_data/config "config -s compact_allocation False"
	deluge-console -c /home/jethros/bt_data/config "config -s ignore_limits_on_local_network True"
	deluge-console -c /home/jethros/bt_data/config "config -s rate_limit_ip_overhead True"

	deluge-console -c /home/jethros/bt_data/config "config -s max_connections_global 200"
	deluge-console -c /home/jethros/bt_data/config "config -s max_upload_slots_global 10"
	deluge-console -c /home/jethros/bt_data/config "config -s max_download_speed -1"
	deluge-console -c /home/jethros/bt_data/config "config -s max_upload_speed -1"
	deluge-console -c /home/jethros/bt_data/config "config -s max_half_open_connections 50"

	deluge-console -c /home/jethros/bt_data/config "config -s max_connections_per_torrent -1"
	deluge-console -c /home/jethros/bt_data/config "config -s max_upload_slots_per_torrent -1"
	deluge-console -c /home/jethros/bt_data/config "config -s max_download_speed_per_torrent -1"
	deluge-console -c /home/jethros/bt_data/config "config -s max_upload_speed_per_torrent -1"

	deluge-console -c /home/jethros/bt_data/config "config -s max_active_limit -1"
	deluge-console -c /home/jethros/bt_data/config "config -s max_active_downloading -1"
	deluge-console -c /home/jethros/bt_data/config "config -s max_active_seeding -1"

	# deluge-console -c /home/jethros/bt_data/config 'config -s max_download_speed_per_torrent 10000'
	# deluge-console -c /home/jethros/bt_data/config 'config -s max_upload_speed_per_torrent 10000'
	# deluge-console -c /home/jethros/bt_data/config 'config -s max_seed_speed_per_torrent 10000'
	# deluge-console -c /home/jethros/bt_data/config 'config -s max_active_limit 10'
	# deluge-console -c /home/jethros/bt_data/config 'config -s max_active_downloading 10'
	# deluge-console -c /home/jethros/bt_data/config 'config -s max_active_seeding 10'
	# deluge-console -c /home/jethros/bt_data/config "config -s max_download_speed 100000"
	# deluge-console -c /home/jethros/bt_data/config "config -s max_upload_speed 100000"

	deluge-console -c /home/jethros/bt_data/config "halt"
fi

echo "Starting up now ..."
nice deluged -c /home/jethros/bt_data/config

# deluge-web -c ~/bt_data/config
