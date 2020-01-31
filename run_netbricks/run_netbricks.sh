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

sed "/duration = 300/i log_path = '$LOG'" $NB_CONFIG > $TMP_NB_CONFIG


echo $LOG_DIR
echo $LOG
mkdir -p $LOG_DIR

if [ $2 == "pvn-p2p-nat-filter" ]; then
	# clean the states of transmission
	sudo rm -rf downloads/*
	sudo rm -rf config/*
	mkdir -p config downloads

	sudo rm -rf /data/downloads/*
	sudo rm -rf /data/config/*
	sudo mkdir -p /data/config /data/downloads

	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
		P1=$!
		$BIO_TOP_MONITOR -C | tee $BIO_LOG &
		P2=$!
		$TCP_TOP_MONITOR -C | tee $TCP_LOG &
		P3=$!
		$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
		P4=$!
		wait $P1 $P2 $P3 $P4

	elif [ $2 == "pvn-p2p-nat-groupby" ]; then
		# clean the states of transmission
		sudo rm -rf downloads/*
		sudo rm -rf config/*
		mkdir -p config downloads

		sudo rm -rf /data/downloads/*
		sudo rm -rf /data/config/*
		sudo mkdir -p /data/config /data/downloads

		while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
			P1=$!
			$BIO_TOP_MONITOR -C | tee $BIO_LOG &
			P2=$!
			$TCP_TOP_MONITOR -C | tee $TCP_LOG &
			P3=$!
			$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
			P4=$!
			wait $P1 $P2 $P3 $P4

		elif [ $2 == "pvn-transcoder-nat-groupby" ]; then

	# clean the states of transcoder
	sudo rm -rf /home/jethros/dev/pvn-utils/data/output_videos/*
	sudo mkdir -p /home/jethros/dev/pvn-utils/data/output_videos/

	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
		P1=$!
		$BIO_TOP_MONITOR -C | tee $BIO_LOG &
		P2=$!
		$TCP_TOP_MONITOR -C | tee $TCP_LOG &
		P3=$!
		$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
		P4=$!
		wait $P1 $P2 $P3 $P4


	elif [ $2 == "pvn-transcoder-nat-filter" ]; then

	# clean the states of transcoder
	sudo rm -rf /home/jethros/dev/pvn-utils/data/output_videos/*
	sudo mkdir -p /home/jethros/dev/pvn-utils/data/output_videos/

	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
		P1=$!
		$BIO_TOP_MONITOR -C | tee $BIO_LOG &
		P2=$!
		$TCP_TOP_MONITOR -C | tee $TCP_LOG &
		P3=$!
		$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
		P4=$!
		wait $P1 $P2 $P3 $P4

	else
		while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
			P1=$!
			$BIO_TOP_MONITOR -C | tee $BIO_LOG &
			P2=$!
			$TCP_TOP_MONITOR -C | tee $TCP_LOG &
			P3=$!
			$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
			P4=$!
			wait $P1 $P2 $P3 $P4

fi
