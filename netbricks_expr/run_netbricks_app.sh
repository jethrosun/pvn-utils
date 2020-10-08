#!/bin/bash
set -e
# set -euo pipefail

# Usage:
#   $ ./run_netbricks.sh trace nf epoch setup expr


LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4.log
MLOG=$LOG_DIR/$3_$4_measurement.log
AMLOG=$LOG_DIR/$3_$4_a_measurement.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4_p2p_progress.log
P2P_WRAPPER_LOG=$LOG_DIR/$3_$4_p2p_run.log
FAKTORY_LOG=$LOG_DIR/$3_$4_faktory.log
IPTRAF_LOG=$LOG_DIR/$3_$4_iptraf.log
# SHORT_IPTRAF_LOG=$3_$4_iptraf.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop
IPTRAF_MONITOR=/usr/sbin/iptraf-ng

NB_CONFIG=$HOME/dev/netbricks/experiments/config_2core.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_2core_long.toml
TMP_NB_CONFIG=$HOME/config.toml

sed "/duration = 750/i log_path = '$LOG'" $NB_CONFIG_LONG > $TMP_NB_CONFIG

echo $LOG_DIR
echo $LOG
mkdir -p $LOG_DIR

INST_LEVEL=off


if [ $2 == 'pvn-transcoder-transform-app' ]; then
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	# P1=$!
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh $4 $5 $6 $7 $FAKTORY_LOG &
	P5=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG > $LOG &
	P1=$!
	while sleep 1; do nice ps aux --sort=-%mem | awk 'NR<=10{print $0}'; done > $MLOG &
	P2=$!
	nice $BIO_TOP_MONITOR -C > $BIO_LOG &
	P3=$!
	nice $TCP_TOP_MONITOR -C > $TCP_LOG &
	P4=$!
	while sleep 60; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/xcdr_mk_space.sh; done  &
	P6=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6

elif  [ $2 == 'pvn-transcoder-groupby-app' ]; then
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_srv --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	# P1=$!
	docker ps
	sleep 15
	# top -b -d 1 -n 700 | tee $MLOG &
	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh $4 $5 $6 $7 $FAKTORY_LOG &
	P5=$!
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG > $LOG &
	P1=$!
	while sleep 1; do nice ps aux --sort=-%mem | awk 'NR<=50{print $0}'; done > $MLOG &
	P2=$!
	nice $BIO_TOP_MONITOR -C > $BIO_LOG &
	P3=$!
	nice $TCP_TOP_MONITOR -C > $TCP_LOG &
	P4=$!
	while sleep 60; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/xcdr_mk_space.sh; done  &
	P6=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6

elif [ $2 == "pvn-p2p-transform-app" ]; then
	if [ $5 == "app_p2p-controlled" ]; then
		sudo rm -rf $HOME/Downloads
		sudo rm -rf /data/bt/config
		mkdir -p $HOME/Downloads  /data/bt/config
	else
		# clean the states of transmission
		sudo rm -rf downloads/*
		sudo rm -rf config/*
		mkdir -p config downloads

		sudo rm -rf /data/downloads/*
		sudo rm -rf /data/config/*
		sudo mkdir -p /data/config /data/downloads
	fi

	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		'{setup: $setup, iter: $iter, inst: $inst, p2p_type: $p2p_type}' )
	echo $JSON_STRING > /home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh

	if [ $5 == "app_p2p-controlled" ]; then
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > $P2P_PROGRESS_LOG &
		P1=$!
	else
		while sleep 1; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_transmission.sh ; done > $P2P_PROGRESS_LOG &
		P1=$!
	fi
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG > $LOG &
	P2=$!
	# if [ $5 == "app_p2p-controlled" ]; then
	#     /home/jethros/dev/pvn/utils/p2p_expr/p2p_run_leecher_wrapper.sh $4 & > $P2P_WRAPPER_LOG &
	#     P6=$!
	# fi
	while sleep 1; do nice ps aux --sort=-%mem | awk 'NR<=50{print $0}'; done > $MLOG &
	P3=$!
	nice $BIO_TOP_MONITOR -C > $BIO_LOG &
	P4=$!
	nice $TCP_TOP_MONITOR -C > $TCP_LOG &
	P5=$!
	wait $P1 $P2 $P3 $P4 $P5 #$P6

elif [ $2 == "pvn-p2p-groupby-app" ]; then
	if [ $5 == "app_p2p-controlled" ]; then
		sudo rm -rf $HOME/Downloads
		sudo rm -rf /data/bt/config
		mkdir -p $HOME/Downloads  /data/bt/config
	else
		# clean the states of transmission
		sudo rm -rf downloads/*
		sudo rm -rf config/*
		mkdir -p config downloads

		sudo rm -rf /data/downloads/*
		sudo rm -rf /data/config/*
		sudo mkdir -p /data/config /data/downloads
	fi

	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		'{setup: $setup, iter: $iter, inst: $inst, p2p_type: $p2p_type}' )
	echo $JSON_STRING > /home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh

	if [ $5 == "app_p2p-controlled" ]; then
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > $P2P_PROGRESS_LOG &
		P1=$!
	else
		while sleep 1; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_transmission.sh ; done > $P2P_PROGRESS_LOG &
		P1=$!
	fi
	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG > $LOG &
	P2=$!

	# if [ $5 == "app_p2p-controlled" ]; then
	#     /home/jethros/dev/pvn/utils/p2p_expr/p2p_run_leecher_wrapper.sh $4 & > $P2P_WRAPPER_LOG &
	#     P6=$!
	# fi
	while sleep 1; do nice ps aux --sort=-%mem | awk 'NR<=50{print $0}'; done > $MLOG &
	P3=$!
	# top -b -d 1 -n 700 | tee $MLOG &
	nice $BIO_TOP_MONITOR -C > $BIO_LOG &
	P4=$!
	nice $TCP_TOP_MONITOR -C > $TCP_LOG &
	P5=$!

	wait $P1 $P2 $P3 $P4 $P5 #$P6

elif [ $2 == "pvn-rdr-transform-app" ]; then
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG > $LOG &
	P1=$!
	while sleep 1; do nice ps aux --sort=-%mem | awk 'NR<=1000{print $0}'; done > $MLOG &
	P2=$!
	nice $BIO_TOP_MONITOR -C > $BIO_LOG &
	P3=$!
	nice $TCP_TOP_MONITOR -C > $TCP_LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

elif [ $2 == "pvn-rdr-groupby-app" ]; then
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, inst: $inst}' )
	echo $JSON_STRING > /home/jethros/setup

	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG > $LOG &
	P1=$!
	while sleep 1; do nice ps aux --sort=-%mem | awk 'NR<=1000{print $0}'; done > $MLOG &
	P2=$!
	# top -b -d 1 -n 700 | tee $MLOG &
	nice $BIO_TOP_MONITOR -C > $BIO_LOG &
	P3=$!
	nice $TCP_TOP_MONITOR -C > $TCP_LOG &
	P4=$!
	wait $P1 $P2 $P3 $P4

else
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, inst: $inst}' )

	$NETBRICKS_BUILD run $2 -f $TMP_NB_CONFIG > $LOG &
	P1=$!
	while sleep 1; do nice ps aux --sort=-%mem | awk 'NR<=50{print $0}'; done > $MLOG &
	P2=$!
	nice $BIO_TOP_MONITOR -C > $BIO_LOG &
	P3=$!
	nice $TCP_TOP_MONITOR -C > $TCP_LOG &
	P4=$!

	wait $P1 $P2 $P3 $P4
fi
