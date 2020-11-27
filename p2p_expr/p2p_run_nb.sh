#!/bin/bash
# set -x

# sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
# sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh

args=("$@")
printf "args %s" "$@"

if [ "$1" == "1" ]; then
	setup=1
elif [ "$1" == "2" ]; then
	setup=2
elif [ "$1" == "3" ]; then
	setup=4
elif [ "$1" == "4" ]; then
	setup=6
elif [ "$1" == "5" ]; then
	setup=8
elif [ "$1" == "6" ]; then
	setup=10
else
	printf "Unknown setup: %s"  "$1"
fi

printf "Running expr %s with setup %s"  "$1" "$setup"
echo Number of arguments: $#

for (( c=1; c<=setup; c++ ))
do
	echo "${args[$c]}"
	sudo -u jethros deluge-console -c /data/bt/config "add /home/jethros/dev/pvn/utils/workloads/torrent_files/p2p_image_${args[$c]}.img.torrent"
done
