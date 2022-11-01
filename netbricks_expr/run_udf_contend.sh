#!/bin/bash
set -e

# cmd_str = "sudo ./run_udf_contend.sh " + trace + " " + nf + " " + str(epoch) + " " + setup + " " + cpu + " " + mem + " " + diskio

# BATCH=400019
# BATCH=664673
# BATCH=1374946
BATCH=contention

# configs
# DELAY_INTERVAL=3
SLEEP_INTERVAL=1

# base log dir
LOG_DIR=$HOME/netbricks_logs/$2/$1

# log files
# 3: number of runs
# 4: *udf_id* for udf_profile; *node id* for udf_schedule
LOG=$LOG_DIR/$3_$4__$5$6$7.log
TCP_LOG=$LOG_DIR/$3_$4__$5$6$7_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4__$5$6$7_biotop.log
DOCKER_STATS_LOG=$LOG_DIR/$3_$4__$5$6$7_docker_stats.log
MPSTAT_LOG=$LOG_DIR/$3_$4__$5$6$7_mpstat.log
# then *core id* and *NF id*
SYNTHETIC_LOG=$LOG_DIR/$3_$4__$5$6$7_srv

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
BIO_TOP_MONITOR="/usr/bin/python3 /usr/share/bcc/tools/biotop"
# PCPU=$HOME/dev/pvn/utils/netbricks_expr/misc/pcpu.sh
# PMEM=$HOME/dev/pvn/utils/netbricks_expr/misc/pmem.sh

NB_CONFIG=$HOME/dev/netbricks/experiments/udf_1core_contention.toml
TMP_NB_CONFIG=$HOME/config.toml

# SERVER=$HOME/data/cargo-target/release/synthetic_srv

# 1800 seconds = 30 min
sed "/duration = 180/i log_path = '${LOG}'" "${NB_CONFIG}" >"${TMP_NB_CONFIG}"
# sed "/duration = 3800/i log_path = '${LOG}'" "${NB_CONFIG}" >"${TMP_NB_CONFIG}"

INST_LEVEL=off
EXPR_MODE=long # bogus config?

mkdir -p "$LOG_DIR"

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


# for tlsv
#   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=cpu $6=mem $7=diskio

# clean previous contention process, if any
for PID in $(pgrep contention); do sudo -u jethros kill $PID; done


sudo /home/jethros/dev/pvn/utils/netbricks_expr/misc/nb_cleanup.sh
sleep 3

# https://www.baeldung.com/ops/docker-logs
truncate -s 0 /var/lib/docker/containers/*/*-json.log

pids=""
RESULT=0


while sleep 5; do
	if [[ $(pgrep contention_cpu) ]]; then
		:
	else
		/home/jethros/dev/pvn/utils/contention_cpu/start.sh "$5" 1 "$CPU_LOG" &
	fi
done &
pids="$pids $!"
while sleep 5; do
	if [[ $(pgrep contention_mem) ]]; then
		:
	else
		sudo taskset -c 5 /home/jethros/dev/pvn/utils/contention_mem/start.sh "$6" "$MEM_LOG" &
	fi
done &
pids="$pids $!"
while sleep 5; do
	if [[ $(pgrep contention_disk) ]]; then
		:
	else
		sudo taskset -c 5 /home/jethros/dev/pvn/utils/contention_diskio/start.sh "$7" 3 "hdd" "$DISKIO_LOG" &
		# sudo taskset -c 5 /home/jethros/dev/pvn/utils/contention_diskio/start.sh "$7" 4 "hdd" "$DISKIO_LOG" &
	fi
done &
contention_diskio_pid=$!
echo "PID" $contention_diskio_pid
pids="$pids $contention_diskio_pid"


# "$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
# pids="$pids $!"

core_id=3

# match NF_id to run docker
#
# {"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}
if [ "$4" == "6" ]; then
	# "6": "tlsv"
	cd ~/dev/pvn/tlsv-builder/
	echo 6 $4 "$core_id"
	docker run -d --cpuset-cpus "$core_id" --name tlsv_6_${core_id} \
		--rm --network=host \
		-v /data/tmp:/data \
		-v /home/jethros/data/traces/pvn_tlsv/tmp:/traces \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
		tlsv:alphine 6 $4 "$core_id"
	docker logs -f tlsv_6_${core_id} &> ${SYNTHETIC_LOG}__6_${core_id}.log &
	pids="$pids $!"

# FIXME: Run P2P seeder and leechers....
elif [ "$4" == "7" ]; then
	# "7": "p2p"
	PORT1=$((58845+core_id))
	PORT2=$((51412+core_id))
	PORT3=$((52800+core_id))
	cd ~/dev/pvn/p2p-builder/
	echo 7 $4 $core_id
	docker run -d --cpuset-cpus $core_id --name p2p_7_${core_id} \
		--rm \
		-p $PORT1:58846 \
		-p $PORT2:51413 \
		-p $PORT3:52801 \
		-v /data/downloads/core_${core_id}:/data \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
		-v /home/jethros/torrents:/torrents \
		p2p:deluge 7 $4 $core_id
	docker logs -f p2p_7_${core_id} &> ${SYNTHETIC_LOG}__7_${core_id}.log &
	pids="$pids $!"

elif [ "$4" == "8" ]; then
	# "8": "rdr"
	cd ~/dev/pvn/rdr-builder/
	echo 8 $4 "$core_id"
	docker run -d --cpuset-cpus $core_id --name rdr_8_${core_id} \
		--rm  --network=host \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
		rdr:alphine 8 $4 $core_id
	docker logs -f rdr_8_${core_id} &> ${SYNTHETIC_LOG}__8_${core_id}.log &
	pids="$pids $!"

else
	# echo $3, $4 # 0, 1
	echo $4 $4 "$core_id" # null, 1, 3
	# {"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}
	cd ~/dev/pvn/utils/synthetic_srv/

	# run docker and collect logs
	# https://www.baeldung.com/ops/docker-logs
	docker run -d --cpuset-cpus $core_id --name synthetic_srv_$4_${core_id} \
		--rm --network=host \
		-v /home/jethros/dev/pvn/utils/data:/udf_data \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
		synthetic:alphine $4 $4 "$core_id"
	docker logs -f synthetic_srv_$4_${core_id} &> ${SYNTHETIC_LOG}__$4_${core_id}.log &
	pids="$pids $!"

fi

docker ps

# docker stats
taskset -c 0 docker stats --no-trunc --format "table {{.Name}} {{.CPUPerc}} {{.MemUsage}} {{.BlockIO}}" >> ${DOCKER_STATS_LOG} &
pids="$pids $!"

while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh pvn; done > "$CPULOG1" &
pids="$pids $!"
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn; done > "$MEMLOG1" &
pids="$pids $!"
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh chrom; done > "$CPULOG2" &
pids="$pids $!"
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom; done > "$MEMLOG2" &
pids="$pids $!"
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh contention; done > "$CPULOG3" &
pids="$pids $!"
while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 5 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh contention; done > "$MEMLOG3" &
pids="$pids $!"


# mpstat for every second
taskset -c 5 mpstat -P ALL 1 >> "$MPSTAT_LOG" &
pids="$pids $!"

# intel PQoS

# Block IO
sudo taskset -c 5 /usr/bin/python3 /usr/share/bcc/tools/biotop -C -p $contention_diskio_pid > "$BIO_LOG" &
pids="$pids $!"

for pid in $pids; do
	wait $pid || let "RESULT=1"
done

if [ "$RESULT" == "1" ];
then
	exit 1
fi

# PID and waits:
# https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0

