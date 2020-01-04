#!/bin/bash

# Usage:
#   $ ./run_netbricks.sh trace nf epoch

set -euo pipefail

LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3.log
MLOG=$LOG_DIR/$3_measurement.log
TCP_LOG=$LOG_DIR/$3_tcptop.log
BIO_LOG=$LOG_DIR/$3_biotop.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop

NB_CONFIG=$HOME/dev/netbricks/experiments/config_2core.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_2core_long.toml
TMP_NB_CONFIG=$HOME/config.toml

sed "/duration = 60/i log_path = '$LOG'" $NB_CONFIG > $TMP_NB_CONFIG


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

	repeat 100 do {ps aux --sort=-%mem | awk 'NR<=10{print $0}'} && sleep 1 | tee $MLOG &
	timeout 90s {$BIO_TOP_MONITOR -C | tee $BIO_LOG} &
	timeout 90s {$TCP_TOP_MONITOR -C | tee $TCP_LOG} &
	$NETBRICKS_BUILD run-full $2 -f $TMP_NB_CONFIG
elif [ $2 == "pvn-rdr-wd" ]; then
	repeat 100 do {ps aux --sort=-%mem | awk 'NR<=10{print $0}'} && sleep 1 | tee $MLOG &
	timeout 90s {$BIO_TOP_MONITOR -C | tee $BIO_LOG} &
	timeout 90s {$TCP_TOP_MONITOR -C | tee $TCP_LOG} &
	$NETBRICKS_BUILD run-full $2 -f $TMP_NB_CONFIG
else
	repeat 100 do {ps aux --sort=-%mem | awk 'NR<=10{print $0}'} && sleep 1 | tee $MLOG &
	timeout 90s {$BIO_TOP_MONITOR -C | tee $BIO_LOG} &
	timeout 90s {$TCP_TOP_MONITOR -C | tee $TCP_LOG} &
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG
fi
