#!/bin/bash
set -e
# set -euo pipefail

# This script runs the non-coresident PVNFs with resource contention

# Usage:
# for transcoder
#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=port $6=xxx
#		$7=expr_num $8=cpu $9=mem $10=diskio
#
# for p2p
#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=p2p_type
#		$6=cpu $7=mem $8=diskio
#
# for tlsv and rdr
#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup	$5=cpu $6=mem $7=diskio


SLEEP_INTERVAL=2
LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4.log
# MLOG=$LOG_DIR/$3_$4_measurement.log
# AMLOG=$LOG_DIR/$3_$4_a_measurement.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
TCPLIFE_LOG=$LOG_DIR/$3_$4_tcplife.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4_p2p_progress.log
# P2P_WRAPPER_LOG=$LOG_DIR/$3_$4_p2p_run.log
FAKTORY_LOG=$LOG_DIR/$3_$4_faktory.log
# IPTRAF_LOG=$LOG_DIR/$3_$4_iptraf.log
CPU_LOG=$LOG_DIR/$3_$4_cpu.log
MEM_LOG=$LOG_DIR/$3_$4_mem.log
DISKIO_LOG=$LOG_DIR/$3_$4_diskio.log

CPULOG1=$LOG_DIR/$3_$4_cpu1.log
CPULOG2=$LOG_DIR/$3_$4_cpu2.log
CPULOG3=$LOG_DIR/$3_$4_cpu3.log
MEMLOG1=$LOG_DIR/$3_$4_mem1.log
MEMLOG2=$LOG_DIR/$3_$4_mem2.log
MEMLOG3=$LOG_DIR/$3_$4_mem3.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
TCP_LIFE_MONITOR=/usr/share/bcc/tools/tcplife
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop
# IPTRAF_MONITOR=/usr/sbin/iptraf-ng

# NB_CONFIG=$HOME/dev/netbricks/experiments/config_2core.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_1core_long.toml
TMP_NB_CONFIG=$HOME/config.toml

# INST_LEVEL=on
INST_LEVEL=off
sed "/duration = 750/i log_path = '$LOG'" "$NB_CONFIG_LONG" > "$TMP_NB_CONFIG"

mkdir -p "$LOG_DIR"

EXPR_MODE=long


if [ "$2" == 'pvn-transcoder-transform-app' ] || [ "$2" == 'pvn-transcoder-groupby-app' ]; then
	#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=port $6=xxx
	#		$7=expr_num $8=cpu $9=mem $10=diskio

	# setup toml file for NetBricks
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, mode: $mode}' )
	echo "$JSON_STRING" > /home/jethros/setup

	# dont track docker, why?
	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	# P1=$!
	docker ps
	sleep 15

	# config contention
	/home/jethros/dev/pvn/utils/contention_cpu/start.sh "$8" "$CPU_LOG" &
	P1=$!
	/home/jethros/dev/pvn/utils/contention_mem/start.sh "$9" "$MEM_LOG" &
	P2=$!
	/home/jethros/dev/pvn/utils/contention_diskio/start.sh "$10" "$DISKIO_LOG" &
	P3=$!

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$5" "$6" "$7" "$FAKTORY_LOG" &
	P4=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG2" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG2" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh contend; done > "$CPULOG3" &
	P10=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh contend; done > "$MEMLOG3" &
	P11=$!
	"$TCP_LIFE_MONITOR" > "$TCPLIFE_LOG" &
	P12=$!
	"$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P13=$!
	"$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P14=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13 $P14

elif [ "$2" == "pvn-p2p-transform-app" ] || [ "$2" == "pvn-p2p-groupby-app" ]; then
	#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=p2p_type
	#		$6=cpu $7=mem $8=diskio
	if [ "$5" == "app_p2p-controlled" ]; then
		sudo rm -rf "$HOME/Downloads"
		sudo rm -rf /data/bt/config
		mkdir -p "$HOME/Downloads"  /data/bt/config
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
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, iter: $iter, inst: $inst, p2p_type: $p2p_type, mode: $mode}' )
	echo "$JSON_STRING" > /home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	if [ "$5" == "app_p2p-controlled" ]; then
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
		P1=$!
	else
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_transmission.sh ; done > "$P2P_PROGRESS_LOG" &
		P1=$!
	fi

	# config contention
	/home/jethros/dev/pvn/utils/contention_cpu/start.sh "$6" "$CPU_LOG" &
	P2=$!
	/home/jethros/dev/pvn/utils/contention_mem/start.sh "$7" "$MEM_LOG" &
	P3=$!
	/home/jethros/dev/pvn/utils/contention_diskio/start.sh "$8" "$DISKIO_LOG" &
	P4=$!

	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG2" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG2" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh contend; done > "$CPULOG3" &
	P10=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh contend; done > "$MEMLOG3" &
	P11=$!
	"$TCP_LIFE_MONITOR" > "$TCPLIFE_LOG" &
	P12=$!
	"$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P13=$!
	"$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P14=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13 $P14

else
	# for tlsv and rdr
	#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup	$5=cpu $6=mem $7=diskio
	#
	# we don't need to check resource usage for tlsv and rdr so we just grep chrom here
	# as well

	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, iter: $iter, inst: $inst, mode: $mode}' )
	echo "$JSON_STRING" > /home/jethros/setup

	# config contention
	/home/jethros/dev/pvn/utils/contention_cpu/start.sh "$5" "$CPU_LOG" &
	P1=$!
	/home/jethros/dev/pvn/utils/contention_mem/start.sh "$6" "$MEM_LOG" &
	P2=$!
	/home/jethros/dev/pvn/utils/contention_diskio/start.sh "$7" "$DISKIO_LOG" &
	P3=$!

	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh contend; done > "$CPULOG3" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh contend; done > "$MEMLOG3" &
	P10=$!
	"$TCP_LIFE_MONITOR" > "$TCPLIFE_LOG" &
	P11=$!
	"$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P12=$!
	"$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P13=$!

	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13
fi
