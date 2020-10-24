#!/bin/bash

# Usage:
#   $ ./run_netbricks.sh trace nf epoch

set -euo pipefail

LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4.log
MLOG=$LOG_DIR/$3_$4_measurement.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
IPTRAF_LOG=$LOG_DIR/$3_$4_iptraf.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop
IPTRAF_MONITOR=/usr/sbin/iptraf-ng

NB_CONFIG=$HOME/dev/netbricks/experiments/config_2core.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_2core_long.toml
TMP_NB_CONFIG=$HOME/config.toml

sed "/duration = 290/i log_path = '$LOG'" $NB_CONFIG_LONG > $TMP_NB_CONFIG

echo $LOG_DIR
echo $LOG
mkdir -p $LOG_DIR

INST_LEVEL=on

if [ $2 == 'pvn-transcoder-transform-app' ]; then
	JSON_STRING=$( jq -n \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, port: $port, expr_num: $expr_num, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	docker run -d --name faktory_src --rm -it -v faktory-data:/var/lib/faktory  -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest /faktory -b :7419 -w :7420
	# P1=$!
	docker ps
	sleep 15
	# top -b -d 1 -n 700 | tee $MLOG &

	while sleep 1; do ps aux --sort=-%cpu | awk 'NR<=50{print $0}'; done | tee $MLOG &
	P2=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P3=$!
	$IPTRAF_MONITOR -s eno1 -L $IPTRAF_LOG &
	P4=$!
	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh $5 $6 $7 &
	P5=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P6=$!
	wait $P2 $P3 $P4 $P5 $P6

elif  [ $2 == 'pvn-transcoder-groupby-app' ]; then
	JSON_STRING=$( jq -n \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, port: $port, expr_num: $expr_num, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	docker run -d --name faktory_srv --rm -it -v faktory-data:/var/lib/faktory  -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest /faktory -b :7419 -w :7420
	# P1=$!
	docker ps
	sleep 15
	# top -b -d 1 -n 700 | tee $MLOG &

	while sleep 1; do ps aux --sort=-%cpu | awk 'NR<=50{print $0}'; done | tee $MLOG &
	P2=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P3=$!
	$IPTRAF_MONITOR -s eno1 -L $IPTRAF_LOG &
	P4=$!
	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh $5 $6 $7 &
	P5=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P6=$!
	wait  $P2 $P3 $P4 $P5 $P6

elif [ $2 == "pvn-p2p-transform-app" ]; then
	# clean the states of transmission
	sudo rm -rf downloads/*
	sudo rm -rf config/*
	mkdir -p config downloads

	sudo rm -rf /data/downloads/*
	sudo rm -rf /data/config/*
	sudo mkdir -p /data/config /data/downloads

	JSON_STRING=$( jq -n \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	while sleep 1; do ps aux --sort=-%cpu | awk 'NR<=50{print $0}'; done | tee $MLOG &
	# top -b -d 1 -n 700 | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$IPTRAF_MONITOR -s eno1 -L $IPTRAF_LOG &
	P3=$!
	$NETBRICKS_BUILD run-full $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

elif [ $2 == "pvn-p2p-groupby-app" ]; then
	# clean the states of transmission
	sudo rm -rf downloads/*
	sudo rm -rf config/*
	mkdir -p config downloads

	sudo rm -rf /data/downloads/*
	sudo rm -rf /data/config/*
	sudo mkdir -p /data/config /data/downloads

	JSON_STRING=$( jq -n \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	while sleep 1; do ps aux --sort=-%cpu | awk 'NR<=50{print $0}'; done | tee $MLOG &
	# top -b -d 1 -n 700 | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$IPTRAF_MONITOR -s eno1 -L $IPTRAF_LOG &
	P3=$!
	$NETBRICKS_BUILD run-full $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

elif [ $2 == "pvn-rdr-transform-app" ]; then
	JSON_STRING=$( jq -n \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	while sleep 1; do ps aux --sort=-%cpu | awk 'NR<=50{print $0}'; done | tee $MLOG &
	# top -b -d 1 -n 700 | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$IPTRAF_MONITOR -s eno1 -L $IPTRAF_LOG &
	P3=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

elif [ $2 == "pvn-rdr-groupby-app" ]; then
	JSON_STRING=$( jq -n \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=1200{print $0}'; done | tee $MLOG &
	# top -b -d 1 -n 700 | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$IPTRAF_MONITOR -s eno1 -L $IPTRAF_LOG &
	P3=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

else

	JSON_STRING=$( jq -n \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, inst: $inst}' )

	while sleep 1; do ps aux --sort=-%mem | awk 'NR<=1200{print $0}'; done | tee $MLOG &
	# top -b -d 1 -n 700 | tee $MLOG &
	P1=$!
	$BIO_TOP_MONITOR -C | tee $BIO_LOG &
	P2=$!
	$IPTRAF_MONITOR -s eno1 -L $IPTRAF_LOG &
	P3=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG | tee $LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

fi