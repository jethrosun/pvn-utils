#!/bin/bash

# Usage:
#   $ ./run_netbricks.sh trace nf epoch

set -euo pipefail

LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4.log
MLOG=$LOG_DIR/$3_$4_measurement.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop

NB_CONFIG=$HOME/dev/netbricks/experiments/config_2core.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_2core_long.toml
TMP_NB_CONFIG=$HOME/config.toml

sed "/duration = 850/i log_path = '$LOG'" $NB_CONFIG_LONG > $TMP_NB_CONFIG



echo $LOG_DIR
echo $LOG
mkdir -p $LOG_DIR

if [ $2 == "pvn-p2p-filter" ]; then
	# clean the states of transmission
	# sudo rm -rf downloads/*
	# sudo rm -rf config/*
	# mkdir -p config downloads
        #
	# sudo rm -rf /data/downloads/*
	# sudo rm -rf /data/config/*
	# sudo mkdir -p /data/config /data/downloads

	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$TCP_TOP_MONITOR -C | tee $TCP_LOG &
	P3=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

elif [ $2 == "pvn-p2p-groupby" ]; then
	# clean the states of transmission
	# sudo rm -rf downloads/*
	# sudo rm -rf config/*
	# mkdir -p config downloads
        #
	# sudo rm -rf /data/downloads/*
	# sudo rm -rf /data/config/*
	# sudo mkdir -p /data/config /data/downloads

	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$TCP_TOP_MONITOR -C | tee $TCP_LOG &
	P3=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

elif [ $2 == "pvn-transcoder-groupby" ]; then

	# clean the states of transcoder
	sudo rm -rf /home/jethros/dev/pvn-utils/data/output_videos/
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


elif [ $2 == "pvn-transcoder-filter" ]; then

	# clean the states of transcoder
	sudo rm -rf /home/jethros/dev/pvn-utils/data/output_videos/
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

elif  [ $2 == 'pvn-transcoder-transform-app' ]; then
	echo '{"setup": '$4'}'\n'{"port": '$5'}' > /home/jethros/setup

	./home/jethros/dev/pvn-utils/faktory_srv/run_faktory_docker.sh $5 $6 &
	P0=$!
	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$TCP_TOP_MONITOR -C | tee $TCP_LOG &
	P3=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	./home/jethros/dev/pvn-utils/faktory_srv/start_faktory.sh $5 &
	P5=$!

	wait $P0 $P1 $P2 $P3 $P4 $P5

elif  [ $2 == 'pvn-transcoder-groupby-app' ]; then
	echo '{"setup": '$4'}'\n'{"port": '$5'}' > /home/jethros/setup

	./home/jethros/dev/pvn-utils/faktory_srv/run_faktory_docker.sh $5 $6 &
	P0=$!
	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$TCP_TOP_MONITOR -C | tee $TCP_LOG &
	P3=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	./home/jethros/dev/pvn-utils/faktory_srv/start_faktory.sh $5 &
	P5=$!

	wait $P0 $P1 $P2 $P3 $P4 $P5 $P6

else
	echo '{"setup": '$4'}' > /home/jethros/setup
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
