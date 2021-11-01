#!/bin/bash
set -ex


sudo -u jethros mkdir -p /home/jethros/Downloads
sudo -u jethros mkdir -p /data/bt/config
sudo -u jethros mkdir -p /data/bt/deluge_data
sudo -u jethros mkdir -p /data/bt/tmp
sudo -u jethros mkdir -p /data/tmp
sudo -u jethros mkdir -p /data/tmp3
sudo -u jethros mkdir -p /data/tmp4

if [ ! -e /data/bt/config/auth ]; then
	sudo -u jethros deluged -c /data/bt/config
	sleep 1

	sudo -u jethros deluge-console -c /data/bt/config "config -s allow_remote True"

	sudo -u jethros deluge-console -c /data/bt/config "config -s move_completed_path /data/bt/deluge_data/Complete"
	sudo -u jethros deluge-console -c /data/bt/config "config -s torrentfiles_location /data/bt/deluge_data/Torrents"
	sudo -u jethros deluge-console -c /data/bt/config "config -s download_location /data/bt/deluge_data/InProgress"
	# sudo -u jethros deluge-console -c /data/bt/config "config -s autoadd_location /data/bt/deluge_data/Drop" # FIXME

	#sudo -u jethros deluge-console -c ~/bt_data/config "config -s daemon_port 58846"
	#sudo -u jethros deluge-console -c ~/bt_data/config "config -s upnp False"
	#sudo -u jethros deluge-console -c ~/bt_data/config "config -s compact_allocation False"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s add_paused False"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s move_completed True"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s copy_torrent_file True"
	# sudo -u jethros deluge-console -c ~/bt_data/config "config -s autoadd_enable True"

	sudo -u jethros deluge-console -c /data/bt/config 'config -s dht false'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s utpex false'
	# sudo -u jethros deluge-console -c /data/bt/config 'config -s cache_size 0'
	# sudo -u jethros deluge-console -c /data/bt/config "config -s compact_allocation True"

	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_limit 10'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_downloading 10'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_active_seeding 10'

	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_download_speed_per_torrent 10000'
	sudo -u jethros deluge-console -c /data/bt/config 'config -s max_upload_speed_per_torrent 10000'
	# sudo -u jethros deluge-console -c /data/bt/config 'config -s max_seed_speed_per_torrent 10000' # FIXME

	sudo -u jethros deluge-console -c /data/bt/config "config -s seed_time_limit 2400"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_download_speed 100000"
	sudo -u jethros deluge-console -c /data/bt/config "config -s max_upload_speed 100000"

	sudo -u jethros deluge-console -c /data/bt/config "halt"
fi

echo "Starting up now ..."
sudo -u jethros taskset -c 1 deluged -c /data/bt/config
# sudo -u jethros deluge-web -c ~/bt_data/config
# sleep 3
# for PID in $(pgrep deluged); do sudo -u jethros taskset -cp 3 $PID; done
