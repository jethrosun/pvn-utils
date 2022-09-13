#!/bin/bash
set -e
# set -euo pipefail

# This script runs the non-coresident PVNFs with resource contention

NB_CONFIG=$HOME/dev/netbricks/experiments/config_1core.toml
NB_CONFIG_MEDIUM=$HOME/dev/netbricks/experiments/config_1core_medium.toml
NB_CONFIG_LONG=$HOME/dev/netbricks/experiments/config_1core_long.toml
TMP_NB_CONFIG=$HOME/config.toml

# ===================================

EXPR_MODE=short
sed "/duration = 200/i log_path = '$LOG'" "$NB_CONFIG" > "$TMP_NB_CONFIG"

# EXPR_MODE=medium
# sed "/duration = 320/i log_path = '$LOG'" "$NB_CONFIG_MEDIUM" > "$TMP_NB_CONFIG"

# EXPR_MODE=long
# sed "/duration = 750/i log_path = '$LOG'" "$NB_CONFIG_LONG" > "$TMP_NB_CONFIG"

# ===================================

SLEEP_INTERVAL=3
LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4__$5$6$7.log
TCP_LOG=$LOG_DIR/$3_$4__$5$6$7_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4__$5$6$7_biotop.log
# TCPLIFE_LOG=$LOG_DIR/$3_$4__$5$6$7_tcplife$5$6$7.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4__$5$6$7_p2p_progress.log
FAKTORY_LOG=$LOG_DIR/$3_$4__$5$6$7_faktory.log
CPU_LOG=$LOG_DIR/$3_$4__$5$6$7_cpu.log
MEM_LOG=$LOG_DIR/$3_$4__$5$6$7_mem.log
DISKIO_LOG=$LOG_DIR/$3_$4__$5$6$7_diskio.log

CHROME_PLOG=$LOG_DIR/$3_$4__$5$6$7_chrome_process.log

CPULOG1=$LOG_DIR/$3_$4__$5$6$7_cpu1.log
CPULOG2=$LOG_DIR/$3_$4__$5$6$7_cpu2.log
CPULOG3=$LOG_DIR/$3_$4__$5$6$7_cpu3.log
MEMLOG1=$LOG_DIR/$3_$4__$5$6$7_mem1.log
MEMLOG2=$LOG_DIR/$3_$4__$5$6$7_mem2.log
MEMLOG3=$LOG_DIR/$3_$4__$5$6$7_mem3.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
# TCP_LIFE_MONITOR=/usr/share/bcc/tools/tcplife
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop


INST_LEVEL=off
mkdir -p "$LOG_DIR"


# for tlsv
#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=cpu $6=mem $7=diskio
for PID in $(pgrep contention); do sudo -u jethros kill $PID; done

JSON_STRING=$( jq -n \
	--arg iter "$3" \
	--arg setup "$4" \
	--arg tlsv_setup "$4" \
	--arg rdr_setup "0" \
	--arg xcdr_setup "0" \
	--arg p2p_setup "0" \
	--arg inst "$INST_LEVEL" \
	--arg mode "$EXPR_MODE" \
	'{setup: $setup,tlsv_setup: $tlsv_setup, rdr_setup: $rdr_setup, xcdr_setup: $xcdr_setup, p2p_setup: $p2p_setup, iter: $iter, inst: $inst, mode: $mode}' )
echo "$JSON_STRING" > /home/jethros/setup

while sleep 5; do
	if [[ $(pgrep contention_cpu) ]]; then
		:
	else
		/home/jethros/dev/pvn/utils/contention_cpu/start.sh "$5" 1 "$CPU_LOG" &
	fi
done &
P1=$!
while sleep 5; do
	if [[ $(pgrep contention_mem) ]]; then
		:
	else
		sudo taskset -c 5 /home/jethros/dev/pvn/utils/contention_mem/start.sh "$6" "$MEM_LOG" &
	fi
done &
P2=$!
while sleep 5; do
	if [[ $(pgrep contention_disk) ]]; then
		:
	else
		sudo taskset -c 5 /home/jethros/dev/pvn/utils/contention_diskio/start.sh "$7" 3 "hdd" "$DISKIO_LOG" &
		sudo taskset -c 5 /home/jethros/dev/pvn/utils/contention_diskio/start.sh "$7" 4 "hdd" "$DISKIO_LOG" &
	fi
done &
P3=$!

"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
P4=$!

while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
P5=$!
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
P6=$!
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
P7=$!
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
P8=$!
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh contention; done > "$CPULOG3" &
P9=$!
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh contention; done > "$MEMLOG3" &
P10=$!
sudo taskset -c 5 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
P11=$!
sudo  taskset -c 5 "$TCP_TOP_MONITOR" -C > "$TCP_LOG" &
P12=$!
wait $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12
