#!/bin/bash
set -e


# cmd_str = "sudo ./run_udf_contend.sh " + trace + " " + nf + " " + str(epoch) + " " + setup

# BATCH=400019
# BATCH=664673
# BATCH=1374946
BATCH=contention

# configs
DELAY_INTERVAL=1
DELAY_INTERVAL=3

# base log dir
LOG_DIR=$HOME/netbricks_logs/$2/$1

# log files
# 3: number of runs
# 4: *udf_id* for udf_profile; *node id* for udf_schedule
LOG=$LOG_DIR/$3_$4.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4_p2p_progress.log
FAKTORY_LOG=$LOG_DIR/$3_$4_faktory.log
DOCKER_STATS_LOG=$LOG_DIR/$3_$4_docker_stats.log
MPSTAT_LOG=$LOG_DIR/$3_$4_mpstat.log
# then *core id* and *NF id*
SYNTHETIC_LOG=$LOG_DIR/$3_$4_srv

# CPULOG1=$LOG_DIR/$3_$4_cpu1.log
# CPULOG2=$LOG_DIR/$3_$4_cpu2.log
# CPULOG3=$LOG_DIR/$3_$4_cpu3.log
# CPULOG4=$LOG_DIR/$3_$4_cpu4.log
# MEMLOG1=$LOG_DIR/$3_$4_mem1.log
# MEMLOG2=$LOG_DIR/$3_$4_mem2.log
# MEMLOG3=$LOG_DIR/$3_$4_mem3.log
# MEMLOG4=$LOG_DIR/$3_$4_mem4.log

NETBRICKS_BUILD=$HOME/dev/netbricks/build.sh
TCP_TOP_MONITOR=/usr/share/bcc/tools/tcptop
BIO_TOP_MONITOR=/usr/share/bcc/tools/biotop

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

sudo /home/jethros/dev/pvn/utils/netbricks_expr/misc/nb_cleanup.sh
sleep 3

# https://www.baeldung.com/ops/docker-logs
truncate -s 0 /var/lib/docker/containers/*/*-json.log

# docker run -d --cpuset-cpus 0 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
pids=""
RESULT=0


"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
pids="$pids $!"

core_id=3

# match NF_id to run docker
#
# {"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}
if ["$4"=="6"]; then
	# "6": "tlsv"
	cd ~/dev/pvn/tlsv-builder/
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
elif ["$4"=="7"]; then
	# "7": "p2p"
	PORT1=$((9090+core_id))
	PORT2=$((51412+core_id))
	cd ~/dev/pvn/p2p-builder/
	docker run -d --cpuset-cpus $core_id --name p2p_7_${core_id} \
		--rm \
		-p $PORT1:9091 \
		-p $PORT2:51413 \
		-p $PORT2:51413/udp \
		-v /data/downloads/core_${core_id}:/downloads \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
		-v /home/jethros/torrents:/torrents \
		p2p:transmission 7 $4 $core_id
	docker logs -f p2p_7_${core_id} &> ${SYNTHETIC_LOG}__7_${core_id}.log &
	pids="$pids $!"

elif ["$4"=="8"]; then
	# "8": "rdr"
	cd ~/dev/pvn/rdr-builder/
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
	# {"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}
	cd ~/dev/pvn/utils/synthetic_srv/

	# run docker and collect logs
	# https://www.baeldung.com/ops/docker-logs
	docker run -d --cpuset-cpus $core_id --name synthetic_srv_${profile_id}_${core_id} \
		--rm --network=host \
		-v /home/jethros/dev/pvn/utils/data:/udf_data \
		-v /data/tmp:/data \
		-v /home/jethros:/config \
		-v /home/jethros/dev/pvn/workload/udf_config:/udf_config \
		-v /home/jethros/dev/pvn/workload/udf_workload/${BATCH}:/udf_workload \
		synthetic:alphine "$profile_id" $4 "$core_id"
	docker logs -f synthetic_srv_${profile_id}_${core_id} &> ${SYNTHETIC_LOG}__${profile_id}_${core_id}.log &
	pids="$pids $!"

fi

docker ps

# docker stats
# https://github.com/moby/moby/issues/22618
# while true; do docker stats -a --no-stream >> ${DOCKER_STATS_LOG}; done &
while true; do taskset -c 0 docker stats --no-stream | tee --append ${DOCKER_STATS_LOG}; sleep 1; done &
pids="$pids $!"

# mpstat for every second
taskset -c 0 mpstat -P ALL 1 >> "$MPSTAT_LOG" &
pids="$pids $!"

# intel PQoS

# Block IO
taskset -c 0 "$BIO_TOP_MONITOR" -C > "$BIO_LOG" &
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


# parameters?
# $1: trace
# $2: nf
# $3: iter
# $4: setup