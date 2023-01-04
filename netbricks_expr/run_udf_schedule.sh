#!/bin/bash
set -e

# base log dir:
# $1 = batch, $2 = schedule
LOG_DIR=$HOME/netbricks_logs/$1/$2
SLEEP_INTERVAL=1

# log files
# 3: number of runs
# 4: *NF id* for udf_profile, and *node id* for udf_schedule
LOG=$LOG_DIR/$3_$4.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4_p2p_progress.log
FAKTORY_LOG=$LOG_DIR/$3_$4_faktory.log
DOCKER_STATS_LOG=$LOG_DIR/$3_$4_docker_stats.log
MPSTAT_LOG=$LOG_DIR/$3_$4_mpstat.log
LOADAVG_LOG=$LOG_DIR/$3_$4_loadavg.log
# then *core id* and *NF id*
SYNTHETIC_LOG=$LOG_DIR/$3_$4_srv
CPULOG=$LOG_DIR/$3_$4_cpu.log
MEMLOG=$LOG_DIR/$3_$4_mem.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
BIO_TOP_MONITOR="/usr/bin/python3 /usr/share/bcc/tools/biotop"

# NB_CONFIG=$HOME/dev/netbricks/experiments/udf_1core_extend.toml
NB_CONFIG=$HOME/dev/netbricks/experiments/udf_1core.toml
TMP_NB_CONFIG=$HOME/config.toml

SERVER=$HOME/data/cargo-target/release/synthetic_srv

# 1800 seconds = 30 min
# sed "/duration = 1800/i log_path = '${LOG}'" "${NB_CONFIG}" >"${TMP_NB_CONFIG}"
# sed "/duration = 3900/i log_path = '${LOG}'" "${NB_CONFIG}" >"${TMP_NB_CONFIG}"
sed "/duration = 3600/i log_path = '${LOG}'" "${NB_CONFIG}" >"${TMP_NB_CONFIG}"

INST_LEVEL=off
EXPR_MODE=long

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

# https://www.baeldung.com/ops/docker-logs
truncate -s 0 /var/lib/docker/containers/*/*-json.log

sudo /home/jethros/dev/pvn/utils/netbricks_expr/misc/nb_cleanup.sh
sleep 3

pids=""
RESULT=0

# P1=$!
"$NETBRICKS_BUILD" run "udf-schedule" -f "$TMP_NB_CONFIG" > "$LOG" &
pids="$pids $!"

# nb_id=$!
# pids="$pids $nb_id"

# TODO: remove?
# Block IO
# taskset -c 0 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pbiotop.sh $nb_id > "$BIO_LOG" &
# pids="$pids $!"

# TODO: remove?
# while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 0 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pcpu.sh udf; done > "$CPULOG" &
# pids="$pids $!"
# while sleep "$SLEEP_INTERVAL"; do sudo -u jethros taskset -c 0 /home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh udf; done > "$MEMLOG" &
# pids="$pids $!"

cd ~/dev/pvn/utils/synthetic_srv/

# {"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}
for core_id in {1..5}
do
	for profile_id in {1..5}
	do
		echo $3 $4 $profile_id "$core_id" # null, 1, 3
		# run docker and collect logs
		# https://www.baeldung.com/ops/docker-logs
		docker run -d --cpuset-cpus $core_id --name synthetic_srv_${profile_id}_${core_id} \
			--rm --network=host \
			-v /home/jethros/dev/pvn/utils/data:/udf_data \
			-v /data/tmp:/data \
			-v /home/jethros:/config \
			-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
			-v /home/jethros/dev/pvn/workload/udf_workload/$1/$2:/udf_workload \
			synthetic:alphine "$profile_id" $4 "$core_id"
		docker logs -f synthetic_srv_${profile_id}_${core_id} &> ${SYNTHETIC_LOG}__${profile_id}_${core_id}.log &
		pids="$pids $!"
		# $SERVER $core_id $profile_id > $LOG_DIR/$3_$4__${core_id}_${profile_id}.log &
		# PID=$!
		# pids="$pids $PID"
		# https://www.baeldung.com/linux/process-periodic-cpu-usage
		# sudo -u jethros taskset -c 0 top -b -d $DELAY_INTERVAL -p $PID | grep -w $PID  > $LOG_DIR/$3_$4__${core_id}_${profile_id}_top.log &
		# pids="$pids $!"
	done
done

for core_id in {1..5}
do
	# "6": "tlsv"
	cd ~/dev/pvn/tlsv-builder/
	docker run -d --cpuset-cpus "$core_id" --name tlsv_6_${core_id} \
		--rm --network=host \
		-v /data/tmp:/data \
		-v /home/jethros/data/traces/pvn_tlsv/tmp:/traces \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/$1/$2:/udf_workload \
		tlsv:alphine 6 $4 "$core_id"
	docker logs -f tlsv_6_${core_id} &> ${SYNTHETIC_LOG}__6_${core_id}.log &
	pids="$pids $!"

	# "7": "p2p"
	PORT1=$((58845+core_id))
	PORT2=$((51412+core_id))
	PORT3=$((52800+core_id))
	cd ~/dev/pvn/p2p-builder/
	docker run -d --cpuset-cpus $core_id --name p2p_7_${core_id} \
		--rm --network=btnet \
		-p $PORT1:58846 \
		-p $PORT2:51413 \
		-p $PORT3:52801 \
		-v /data/downloads/core_${core_id}:/data \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/$1/$2:/udf_workload \
		-v /home/jethros/torrents:/torrents \
		p2p:deluge 7 $4 $core_id
	docker logs -f p2p_7_${core_id} &> ${SYNTHETIC_LOG}__7_${core_id}.log &
	pids="$pids $!"

	# "8": "rdr"
	cd ~/dev/pvn/rdr-builder/
	docker run -d --cpuset-cpus $core_id --name rdr_8_${core_id} \
		--rm  --network=host \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/$1/$2:/udf_workload \
		rdr:alphine 8 $4 $core_id
	docker logs -f rdr_8_${core_id} &> ${SYNTHETIC_LOG}__8_${core_id}.log &
	pids="$pids $!"

done

docker ps

# docker stats
taskset -c 0 docker stats --no-trunc --format "table {{.Name}} {{.CPUPerc}} {{.MemUsage}} {{.BlockIO}}" >> ${DOCKER_STATS_LOG} &
pids="$pids $!"

# TODO: remove?
# mpstat for every second
# taskset -c 0 mpstat -P ALL 1 >> "$MPSTAT_LOG" &
# pids="$pids $!"

# loadavg
while sleep 1; do taskset -c 0 cat /proc/loadavg; done > "$LOADAVG_LOG" &
pids="$pids $!"

# intel PQoS

for pid in $pids; do
	wait $pid || let "RESULT=1"
done

if [ "$RESULT" == "1" ];
then
	exit 1
fi

# PID and waits:
# https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
