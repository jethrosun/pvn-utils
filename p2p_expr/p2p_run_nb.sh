#!/bin/bash
# set -x

# sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh

args=("$@")
printf "args %s" "$@"

setup=${args[0]}

printf "\nRunning expr %s with setup %s"  "$1" "$setup"
echo Number of arguments: $#

for (( c=1; c<=setup; c++ ))
do
	echo "${args[$c]}"
	sudo -u jethros deluge-console -c /data/bt/config "add /home/jethros/dev/pvn/utils/workloads/torrent_files/p2p_image_${args[$c]}.img.torrent"
done

PID=$(pgrep deluged)
sudo -u jethros taskset -cp 3 $PID
