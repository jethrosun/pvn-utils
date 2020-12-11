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

SLEEP_INTERVAL=1
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
# SHORT_IPTRAF_LOG=$3_$4_iptraf.log

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

# NB_CONFIG=$HOME/dev/netbricks/experiments/config_1core.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_1core_long.toml
TMP_NB_CONFIG=$HOME/config.toml

sed "/duration = 750/i log_path = '${LOG}'" "${NB_CONFIG_LONG}" >"${TMP_NB_CONFIG}"

# echo "$(LOG_DIR)"
# echo $LOG
mkdir -p "$LOG_DIR"

INST_LEVEL=off

if [ "$2" == 'pvn-tlsv-rdr-coexist-app' ]; then
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst}')
	echo "${JSON_STRING}" >"/home/jethros/setup"

	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" >"$LOG" &
	P1=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done >"${CPULOG1}" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done >"${MEMLOG1}" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done >"${CPULOG2}" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done >"${MEMLOG2}" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done >"${CPULOG3}" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done >"${MEMLOG3}" &
	P8=$!
	$TCP_LIFE_MONITOR >"${TCPLIFE_LOG}" &
	P9=$!
	$BIO_TOP_MONITOR -C >"${BIO_LOG}" &
	P10=$!
	$TCP_TOP_MONITOR -C >"${TCP_LOG}" &
	P11=$!
	wait $P1 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11

elif [ "$2" == 'pvn-rdr-p2p-coexist-app' ]; then
	if [ "${5}" == "app_p2p-controlled" ]; then
		sudo rm -rf "$HOME/Downloads"
		sudo rm -rf /data/bt/config
		mkdir -p "$HOME/Downloads" /data/bt/config
	else
		# clean the states of transmission
		sudo rm -rf downloads/*
		sudo rm -rf config/*
		mkdir -p config downloads

		sudo rm -rf /data/downloads/*
		sudo rm -rf /data/config/*
		sudo mkdir -p /data/config /data/downloads
	fi

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		'{setup: $setup, iter: $iter, inst: $inst, p2p_type: $p2p_type}')
	echo "${JSON_STRING}" >/home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	if [ "$5" == "app_p2p-controlled" ]; then
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh; done >"${P2P_PROGRESS_LOG}" &
		P1=$!
	else
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_transmission.sh; done >"${P2P_PROGRESS_LOG}" &
		P1=$!
	fi
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	$TCP_LIFE_MONITOR > "${TCPLIFE_LOG}" &
	P9=$!
	$BIO_TOP_MONITOR -C > "${BIO_LOG}" &
	P10=$!
	$TCP_TOP_MONITOR -C > "${TCP_LOG}" &
	P11=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11

elif [ "$2" == 'pvn-rdr-xcdr-coexist-app' ]; then
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst}')
	echo "${JSON_STRING}" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	# P1=$!
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$5" "$6" "$7" "$FAKTORY_LOG" &
	P2=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P1=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG3" &
	P8=$!
	$TCP_LIFE_MONITOR > "$TCPLIFE_LOG" &
	P9=$!
	$BIO_TOP_MONITOR -C > "$BIO_LOG" &
	P10=$!
	$TCP_TOP_MONITOR -C > "$TCP_LOG" &
	P11=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11

elif [ "$2" == 'pvn-tlsv-p2p-coexist-app' ]; then
	if [ "$5" == "app_p2p-controlled" ]; then
		sudo rm -rf "$HOME/Downloads"
		sudo rm -rf /data/bt/config
		mkdir -p "$HOME/Downloads" /data/bt/config
	else
		# clean the states of transmission
		sudo rm -rf downloads/*
		sudo rm -rf config/*
		mkdir -p config downloads

		sudo rm -rf /data/downloads/*
		sudo rm -rf /data/config/*
		sudo mkdir -p /data/config /data/downloads
	fi

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		'{setup: $setup, iter: $iter, inst: $inst, p2p_type: $p2p_type}')
	echo "$JSON_STRING" >/home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	if [ "$5" == "app_p2p-controlled" ]; then
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh; done > "$P2P_PROGRESS_LOG" &
		P1=$!
	else
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_transmission.sh; done > "$P2P_PROGRESS_LOG" &
		P1=$!
	fi
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	"$TCP_LIFE_MONITOR" > "$TCPLIFE_LOG" &
	P9=$!
	"$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P10=$!
	"$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P11=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11

elif [ "$2" == 'pvn-tlsv-xcdr-coexist-app' ]; then
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst}')
	echo "$JSON_STRING" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	# P1=$!
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$5" "$6" "$7" "$FAKTORY_LOG" &
	P2=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P1=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG3" &
	P8=$!
	"$TCP_LIFE_MONITOR" > "$TCPLIFE_LOG" &
	P9=$!
	"$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P10=$!
	"$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P11=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11

elif [ "$2" == 'pvn-xcdr-p2p-coexist-app' ]; then
	if [ "$5" == "app_p2p-controlled" ]; then
		sudo rm -rf "$HOME/Downloads"
		sudo rm -rf /data/bt/config
		mkdir -p "$HOME/Downloads" /data/bt/config
	else
		# clean the states of transmission
		sudo rm -rf downloads/*
		sudo rm -rf config/*
		mkdir -p config downloads

		sudo rm -rf /data/downloads/*
		sudo rm -rf /data/config/*
		sudo mkdir -p /data/config /data/downloads
	fi

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg p2p_type "$8" \
		--arg inst "$INST_LEVEL" \
		'{setup: $setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, p2p_type: $p2p_type}')
	echo "$JSON_STRING" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	# P1=$!
	docker ps
	sleep 15

	if [ "$5" == "app_p2p-controlled" ]; then
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh; done > "$P2P_PROGRESS_LOG" &
		P12=$!
	else
		while sleep 5; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_transmission.sh; done > "$P2P_PROGRESS_LOG" &
		P12=$!
	fi
	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$5" "$6" "$7" "$FAKTORY_LOG" &
	P1=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG3" &
	P8=$!
	"$TCP_LIFE_MONITOR" > "$TCPLIFE_LOG" &
	P9=$!
	"$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P10=$!
	"$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P11=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12
fi
