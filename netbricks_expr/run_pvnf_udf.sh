#!/bin/bash
set -e

# PID and waits:
# https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0


# parameters?
# $1: trace
# $2: nf
# $3: iter
# $4: setup

DELAY_INTERVAL=1
DELAY_INTERVAL=3
LOG_DIR=$HOME/netbricks_logs/$2/$1

LOG=$LOG_DIR/$3_$4.log
TCP_LOG=$LOG_DIR/$3_$4_tcptop.log
BIO_LOG=$LOG_DIR/$3_$4_biotop.log
P2P_PROGRESS_LOG=$LOG_DIR/$3_$4_p2p_progress.log
FAKTORY_LOG=$LOG_DIR/$3_$4_faktory.log
DOCKER_STATS_LOG=$LOG_DIR/$3_$4_docker_stats.log
SYNTHETIC_LOG=$LOG_DIR/$3_$4_srv

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

PCPU=$HOME/dev/pvn/utils/netbricks_expr/misc/pcpu.sh
PMEM=$HOME/dev/pvn/utils/netbricks_expr/misc/pmem.sh

NB_CONFIG=$HOME/dev/netbricks/experiments/udf_1core.toml
TMP_NB_CONFIG=$HOME/config.toml

SERVER=$HOME/data/cargo-target/release/synthetic_srv

# 1800 seconds = 30 min
sed "/duration = 1800/i log_path = '${LOG}'" "${NB_CONFIG}" >"${TMP_NB_CONFIG}"

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

docker run -d --cpuset-cpus 0 --name faktory_src --rm -it -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest
docker ps
sleep 10

pids=""
RESULT=0

# /home/jethros/dev/pvn/utils/faktory_srv/start_faktory.sh "$4" "$7" "$FAKTORY_LOG" &
# P1=$!
"$NETBRICKS_BUILD" run "$2" -f "$TMP_NB_CONFIG" > "$LOG" &
pids="$pids $!"


cd ~/dev/pvn/utils/synthetic_srv/

for core_id in {1..5}
do
	for profile_id in {1..8}
	do
		# run docker and collect logs
		# https://www.baeldung.com/ops/docker-logs
		docker run -d --cpuset-cpus $core_id --name synthetic_srv_${core_id}_${profile_id} \
			--rm -ti --network=host \
			-v /data/tmp:/data \
			-v /home/jethros:/config \
			-v /home/jethros/dev/pvn/utils/workloads/udf:/tmp/udf \
			synthetic:alphine $core_id $profile_id
		docker logs -f synthetic_srv_${core_id}_${profile_id} &> ${SYNTHETIC_LOG}__${core_id}_${profile_id}.log &
		pids="$pids $!"
		# $SERVER $core_id $profile_id > $LOG_DIR/$3_$4__${core_id}_${profile_id}.log &
		# PID=$!
		# pids="$pids $PID"
		# https://www.baeldung.com/linux/process-periodic-cpu-usage
		# sudo -u jethros taskset -c 0 top -b -d $DELAY_INTERVAL -p $PID | grep -w $PID  > $LOG_DIR/$3_$4__${core_id}_${profile_id}_top.log &
		# pids="$pids $!"
	done
done

docker ps

# docker stats
# https://github.com/moby/moby/issues/22618
# while true; do docker stats -a --no-stream >> ${DOCKER_STATS_LOG}; done &
while true; do docker stats --no-stream | tee --append ${DOCKER_STATS_LOG}; sleep 1; done &

# mpstat

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
