#!/bin/bash
set -e
# set -euo pipefail

# Usage:
#   $ ./run_netbricks.sh trace nf epoch setup expr

# PS to collect long running processes' stat
# https://unix.stackexchange.com/questions/215671/can-i-use-ps-aux-along-with-o-etime
# https://unix.stackexchange.com/questions/58539/top-and-ps-not-showing-the-same-cpu-result
#
# ps -e -o user,pid,%cpu,%mem,vsz,rss,start,time,command,etime,etimes,euid --sort=-%mem

SLEEP_INTERVAL=3
LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4_p2p_progress.log
FAKTORY_LOG=$LOG_DIR/$3_$4_faktory.log

CPULOG1=$LOG_DIR/$3_$4_cpu1.log
CPULOG2=$LOG_DIR/$3_$4_cpu2.log
MEMLOG1=$LOG_DIR/$3_$4_mem1.log
MEMLOG2=$LOG_DIR/$3_$4_mem2.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop

NB_CONFIG=$HOME/dev/netbricks/experiments/config_1core.toml
TMP_NB_CONFIG=$HOME/config.toml

sed "/duration = 200/i log_path = '$LOG'" "$NB_CONFIG" > "$TMP_NB_CONFIG"

# INST_LEVEL=on
INST_LEVEL=off
EXPR_MODE=short

mkdir -p "$LOG_DIR"

if [ "$2" == 'pvn-transcoder-transform-app' ] || [ "$2" == 'pvn-transcoder-groupby-app' ]; then
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "0" \
        --arg rdr_setup "0" \
        --arg xcdr_setup "$4" \
        --arg p2p_setup "0" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, mode: $mode}' )
	echo "$JSON_STRING" > /home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 5

	sudo taskset -c 1 /home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$7" "$FAKTORY_LOG" &
	P1=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG2" &
	P6=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P7=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P8=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8

elif [ "$2" == "pvn-p2p-transform-app" ] || [ "$2" == "pvn-p2p-groupby-app" ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads"  /data/bt/config

	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "0" \
        --arg rdr_setup "0" \
        --arg xcdr_setup "0" \
        --arg p2p_setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, inst: $inst, p2p_type: $p2p_type, mode: $mode}' )
	echo "$JSON_STRING" > /home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
	P1=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG2" &
	P6=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P7=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P8=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8

elif [ "$2" == "pvn-tlsv-transform-app" ] || [ "$2" == "pvn-tlsv-groupby-app" ]; then
	# we don't need to check resource usage for tlsv so we just grep chrom here
	# as well
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
        --arg rdr_setup "0" \
        --arg xcdr_setup "0" \
        --arg p2p_setup "0" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, inst: $inst, mode: $mode}' )
	echo "$JSON_STRING" > /home/jethros/setup

	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P1=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P5=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P6=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P7=$!

	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8

elif [ "$2" == "pvn-rdr-transform-app" ] || [ "$2" == "pvn-rdr-groupby-app" ]; then
	# we don't need to check resource usage for tlsv so we just grep chrom here
	# as well
	JSON_STRING=$( jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "0" \
        --arg rdr_setup "$4" \
        --arg xcdr_setup "0" \
        --arg p2p_setup "0" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, inst: $inst, mode: $mode}' )
	echo "$JSON_STRING" > /home/jethros/setup

	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P1=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P5=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P6=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P7=$!

	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8

else
	echo "$2"
    echo "This should not be reached"
fi
