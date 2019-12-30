#!/bin/bash

# Usage:
#   $ ./run_netbricks.sh trace nf epoch

set -euo pipefail

LOG_DIR=$HOME/netbricks_logs/$2/$1/
LOG=$LOG_DIR/$3.log
NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
NB_CONFIG=$HOME/dev/netbricks/experiments/config_2core.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_2core_long.toml

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

	$NETBRICKS_BUILD run-full $2 -f $NB_CONFIG | tee $LOG &&
		ps aux --sort=-%mem | awk 'NR<=10{print $0}'
elif [ $2 == "pvn-rdr-wd" ]; then
	$NETBRICKS_BUILD run-full $2 -f $NB_CONFIG | tee $LOG &&
		ps aux --sort=-%mem | awk 'NR<=10{print $0}'
else
	$NETBRICKS_BUILD run $2 -f $NB_CONFIG | tee $LOG && 
		ps aux --sort=-%mem | awk 'NR<=10{print $0}'
fi
