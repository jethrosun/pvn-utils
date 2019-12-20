#!/bin/bash

# Usage:
#   $ ./run_netbricks.sh trace nf epoch

set -euo pipefail

NB_CONFIG=$HOME/dev/netbricks/experiments/config_2core.toml
NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
LOG_DIR=$HOME/netbricks_logs/$2/$1/
LOG=$LOG_DIR/$3.log

echo $LOG_DIR
echo $LOG
mkdir -p $LOG_DIR

if [ $2 == "pvn-p2p" ]; then
	# clean the states of transmission
	sudo rm -rf downloads/*
	sudo rm -rf config/*
	mkdir -p config downloads

	sudo rm -rf /data/downloads/*
	sudo rm -rf /data/config/*
	sudo mkdir -p /data/config /data/downloads

	$NETBRICKS_BUILD run $2 -f $NB_CONFIG | tee $LOG
else
	$NETBRICKS_BUILD run $2 -f $NB_CONFIG | tee $LOG
fi
