#!/bin/bash
set -e

SLEEP_INTERVAL=3
LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4_p2p_progress.log
FAKTORY_LOG=$LOG_DIR/$3_$4_faktory.log

CPULOG1=$LOG_DIR/$3_$4_cpu1.log
CPULOG2=$LOG_DIR/$3_$4_cpu2.log
CPULOG3=$LOG_DIR/$3_$4_cpu3.log
CPULOG4=$LOG_DIR/$3_$4_cpu4.log
MEMLOG1=$LOG_DIR/$3_$4_mem1.log
MEMLOG2=$LOG_DIR/$3_$4_mem2.log
MEMLOG3=$LOG_DIR/$3_$4_mem3.log
MEMLOG4=$LOG_DIR/$3_$4_mem4.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop

NB_CONFIG=$HOME/dev/netbricks/experiments/config_1core.toml
TMP_NB_CONFIG=$HOME/config.toml

sed "/duration = 200/i log_path = '${LOG}'" "${NB_CONFIG}" >"${TMP_NB_CONFIG}"

INST_LEVEL=off
EXPR_MODE=short

mkdir -p "$LOG_DIR"

if [ "$2" == 'pvn-tlsv-rdr-coexist-app' ]; then
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
                --arg rdr_setup "$4" \
		--arg xcdr_setup "0" \
                --arg p2p_setup "0" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, mode: $mode}')
	echo "${JSON_STRING}" >"/home/jethros/setup"

	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" >"$LOG" &
	P1=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P2=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG2" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG2" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P9=$!
	taskset -c 5 $BIO_TOP_MONITOR -C >"${BIO_LOG}" &
	P10=$!
	taskset -c 5 $TCP_TOP_MONITOR -C >"${TCP_LOG}" &
	P11=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11

elif [ "$2" == 'pvn-rdr-p2p-coexist-app' ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads" /data/bt/config

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "0" \
                --arg rdr_setup "$4" \
                --arg xcdr_setup "0" \
                --arg p2p_setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, inst: $inst, p2p_type: $p2p_type, mode: $mode}')
	echo "${JSON_STRING}" >/home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep 10; do for PID in $(pgrep deluge); do sudo taskset -cp 3 $PID; done; done  &
	P13=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
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
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P10=$!
	taskset -c 5 $BIO_TOP_MONITOR -C > "${BIO_LOG}" &
	P11=$!
	taskset -c 5 $TCP_TOP_MONITOR -C > "${TCP_LOG}" &
	P12=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13
# FIXME
elif [ "$2" == 'pvn-rdr-xcdr-coexist-app' ]; then
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "0" \
                --arg rdr_setup "$4" \
                --arg xcdr_setup "$4" \
                --arg p2p_setup "0" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, mode: $mode}')
	echo "${JSON_STRING}" >/home/jethros/setup
	#"sudo ./run_pvnf_coresident.sh " + trace + " " + nf + " " + str(epoch) + " " + setup + " " + str(expr)

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$7" "$FAKTORY_LOG" &
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
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P10=$!
	taskset -c 5 $BIO_TOP_MONITOR -C > "$BIO_LOG" &
	P11=$!
	taskset -c 5 $TCP_TOP_MONITOR -C > "$TCP_LOG" &
	P12=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12

elif [ "$2" == 'pvn-tlsv-p2p-coexist-app' ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads" /data/bt/config

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
                --arg rdr_setup "0" \
                --arg xcdr_setup "0" \
                --arg p2p_setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, inst: $inst, p2p_type: $p2p_type, mode: $mode}')
	echo "$JSON_STRING" >/home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep 10; do for PID in $(pgrep deluge); do sudo taskset -cp 3 $PID; done; done  &
	P13=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
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
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P10=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P11=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P12=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13

elif [ "$2" == 'pvn-tlsv-xcdr-coexist-app' ]; then
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
                --arg rdr_setup "0" \
                --arg xcdr_setup "$4" \
                --arg p2p_setup "0" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, mode: $mode}')
	echo "$JSON_STRING" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$7" "$FAKTORY_LOG" &
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
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P10=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P11=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P12=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12

elif [ "$2" == 'pvn-xcdr-p2p-coexist-app' ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads" /data/bt/config

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "0" \
                --arg rdr_setup "0" \
                --arg xcdr_setup "$4" \
                --arg p2p_setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg p2p_type "$8" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, p2p_type: $p2p_type, mode: $mode}')
	echo "$JSON_STRING" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 15
	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$7" "$FAKTORY_LOG" &
	P1=$!

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep 10; do for PID in $(pgrep deluge); do sudo taskset -cp 3 $PID; done; done  &
	P14=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
	P2=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG2" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P10=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P11=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P12=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P13=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13 $P14

elif [ "$2" == 'pvn-tlsv-rdr-xcdr-coexist-app' ]; then
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
                --arg rdr_setup "$4" \
                --arg xcdr_setup "$4" \
                --arg p2p_setup "0" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, mode: $mode}')
	echo "${JSON_STRING}" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4"  "$7" "$FAKTORY_LOG" &
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
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P10=$!
	taskset -c 5 $BIO_TOP_MONITOR -C > "$BIO_LOG" &
	P11=$!
	taskset -c 5 $TCP_TOP_MONITOR -C > "$TCP_LOG" &
	P12=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12

# FIXME
elif [ "$2" == 'pvn-tlsv-rdr-p2p-coexist-app' ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads" /data/bt/config
	# nf + str(epoch) + setup + str(expr)

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
                --arg rdr_setup "$4" \
                --arg xcdr_setup "0" \
                --arg p2p_setup "$4" \
		--arg inst "$INST_LEVEL" \
		--arg p2p_type "$5" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup, iter: $iter, inst: $inst, p2p_type: $p2p_type, mode: $mode}')
	echo "${JSON_STRING}" >/home/jethros/setup

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep 10; do for PID in $(pgrep deluge); do sudo taskset -cp 3 $PID; done; done  &
	P13=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
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
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P10=$!
	taskset -c 5 $BIO_TOP_MONITOR -C > "${BIO_LOG}" &
	P11=$!
	taskset -c 5 $TCP_TOP_MONITOR -C > "${TCP_LOG}" &
	P12=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13

elif [ "$2" == 'pvn-rdr-xcdr-p2p-coexist-app' ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads" /data/bt/config

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "0" \
                --arg rdr_setup "$4" \
                --arg xcdr_setup "$4" \
                --arg p2p_setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg p2p_type "$8" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, p2p_type: $p2p_type, mode: $mode}')
	echo "$JSON_STRING" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4"  "$7" "$FAKTORY_LOG" &
	P1=$!

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep 10; do for PID in $(pgrep deluge); do sudo taskset -cp 3 $PID; done; done  &
	P14=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
	P2=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG2" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P10=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P11=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P12=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P13=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13 $P14

elif [ "$2" == 'pvn-tlsv-p2p-xcdr-coexist-app' ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads" /data/bt/config

	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
                --arg rdr_setup "0" \
                --arg xcdr_setup "$4" \
                --arg p2p_setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg p2p_type "$8" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup,  iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, p2p_type: $p2p_type, mode: $mode}')
	echo "$JSON_STRING" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 15
	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$7" "$FAKTORY_LOG" &
	P1=$!

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep 10; do for PID in $(pgrep deluge); do sudo taskset -cp 3 $PID; done; done  &
	P14=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
	P2=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG2" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P10=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P11=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P12=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P13=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13 $P14

elif [ "$2" == 'pvn-tlsv-rdr-p2p-xcdr-coexist-app' ]; then
	sudo rm -rf "$HOME/Downloads"
	sudo rm -rf /data/bt/config
	mkdir -p "$HOME/Downloads" /data/bt/config
	# nf + str(epoch) + setup + str(7419) + str(7420) + str(expr_num) + str(expr)k
	JSON_STRING=$(jq -n \
		--arg iter "$3" \
		--arg setup "$4" \
		--arg tlsv_setup "$4" \
                --arg rdr_setup "$4" \
                --arg xcdr_setup "$4" \
                --arg p2p_setup "$4" \
		--arg port "$5" \
		--arg expr_num "$7" \
		--arg p2p_type "$8" \
		--arg inst "$INST_LEVEL" \
		--arg mode "$EXPR_MODE" \
		'{setup: $setup, tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup, iter: $iter, port: $port, expr_num: $expr_num, inst: $inst, p2p_type: $p2p_type, mode: $mode}')
	echo "$JSON_STRING" >/home/jethros/setup

	docker run -d --cpuset-cpus 4 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
	docker ps
	sleep 15

	/home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4"  "$7" "$FAKTORY_LOG" &
	P1=$!

	sudo /home/jethros/dev/pvn/utils/p2p_expr/p2p_cleanup_nb.sh
	sleep 5
	sudo -u jethros /home/jethros/dev/pvn/utils/p2p_expr/p2p_config_nb.sh
	sleep 15

	while sleep 10; do for PID in $(pgrep deluge); do sudo taskset -cp 3 $PID; done; done  &
	P14=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/mon_finished_deluge.sh ; done > "$P2P_PROGRESS_LOG" &
	P2=$!
	"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
	P3=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
	P4=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
	P5=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh faktory; done > "$CPULOG2" &
	P6=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory; done > "$MEMLOG2" &
	P7=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh deluge; done > "$CPULOG3" &
	P8=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge; done > "$MEMLOG3" &
	P9=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG4" &
	P10=$!
	while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG4" &
	P11=$!
	taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
	P12=$!
	taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
	P13=$!
	wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13 $P14

else
        echo "$2"
        echo "This should not be reached"
fi
