#!/bin/bash
set -ex

BATCH=contention

# run p2p builder in leecher branch
echo "Run P2P builder in leecher mode"

cd ~/dev/pvn/p2p-builder/
docker run -d --name leecher --rm \
	-p 9091:9091 \
	-p 51413:51413 \
	-p 51413:51413/udp \
	-v /home/jethros/data/downloads:/downloads \
	-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
	-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
	-v /home/jethros/torrents:/torrents \
	p2p:leecher
