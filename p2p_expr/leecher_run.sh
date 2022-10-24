#!/bin/bash
set -ex

echo $1 $2 $3

# run p2p builder in leecher branch
echo "Run P2P builder in leecher mode"

echo "Starting up now ..."
deluged -c /home/jethros/bt_data/config

# docker run -d --network=host \
# 	--name leecher --rm \
# 	-p 51413:51413 \
# 	-p 51413:51413/udp \
# 	-v /home/jethros/data/downloads:/downloads \
# 	-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
# 	-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
# 	-v /home/jethros/torrents:/torrents \
# 	p2p:leecher


# need to run bin directly
cd ~/dev/pvn/p2p-builder/
cargo r --release $1 $2
