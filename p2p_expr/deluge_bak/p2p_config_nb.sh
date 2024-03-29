#!/bin/bash
set -ex


sudo -u jethros mkdir -p /home/jethros/Downloads
sudo -u jethros mkdir -p /data/bt/config
sudo -u jethros mkdir -p /data/bt/deluge_data
sudo -u jethros mkdir -p /data/bt/tmp/profile
sudo -u jethros mkdir -p /data/tmp
sudo -u jethros mkdir -p /data/tmp3
sudo -u jethros mkdir -p /data/tmp4

# to properly config deluge, see
#
# 	https://dev.deluge-torrent.org/wiki/UserGuide/BandwidthTweaking
if [ ! -e /data/bt/config/auth ]; then
	sudo -u jethros deluged -c /data/bt/config
	sleep 1

	sudo -u jethros deluge-console -c /data/bt/config "config -s allow_remote True"

	sudo -u jethros deluge-console -c /data/bt/config "config -s move_completed_path /data/bt/deluge_data/Complete"
	sudo -u jethros deluge-console -c /data/bt/config "config -s torrentfiles_location /data/bt/deluge_data/Torrents"
	sudo -u jethros deluge-console -c /data/bt/config "config -s download_location /data/bt/deluge_data/InProgress"
	sudo -u jethros deluge-console -c /data/bt/config "config -s ignore_limits_on_local_network True"
	sudo -u jethros deluge-console -c /data/bt/config "config -s rate_limit_ip_overhead True"

	sudo -u jethros deluge-console -c /data/bt/config 'config -s dht false'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s utpex false'
	sudo -u jethros deluge-console -c /data/bt/config "config -s compact_allocation False"

	sudo -u jethros deluge-console -c /data/bt/config "config -s max_connections_global 200"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_upload_slots_global 0"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_download_speed -1"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_upload_speed 0"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_half_open_connections 50"

	sudo -u jethros deluge-console -c /data/bt/config "config -s max_connections_per_torrent 120"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_upload_slots_per_torrent 0"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_download_speed_per_torrent -1"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_upload_speed_per_torrent 0"

	sudo -u jethros deluge-console -c /data/bt/config "config -s max_active_limit -1"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_active_downloading -1"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_active_seeding 0"

	# sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_limit 10'
	# sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_downloading 10'
	# sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_seeding 10'
	# sudo -u jethros deluge-console -c /data/bt/config 'config -s max_download_speed_per_torrent 10000'
	# sudo -u jethros deluge-console -c /data/bt/config 'config -s max_upload_speed_per_torrent 10000'
	# sudo -u jethros deluge-console -c /data/bt/config "config -s max_download_speed 100000"
	# sudo -u jethros deluge-console -c /data/bt/config "config -s max_upload_speed 100000"

	sudo -u jethros deluge-console -c /data/bt/config "halt"
fi

echo "Starting up now ..."
sudo -u jethros taskset -c 3 deluged -c /data/bt/config
