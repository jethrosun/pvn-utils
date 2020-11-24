#!/bin/bash

PKTGEN_SCRIPT=$HOME/dev/pktgen-dpdk/app/x86_64-native-linuxapp-gcc/pktgen
# FIXME
TRACE_DIR=$HOME/traces/$1
LOG_DIR=$HOME/pktgen_logs/

printf "Running pktgen"
echo $@
echo $TRACE_DIR

# 382 M
# sudo -E app/x86_64-native-linuxapp-gcc/pktgen -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -s 0:large-traces/huge-trace.pcap


echo $LOG_DIR
mkdir -p $LOG_DIR/

if [ $1 == "64B" ]; then
	sudo -E $PKTGEN_SCRIPT -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -l $LOG_DIR$@.log
elif [ $1 == "128B" ]; then
	sudo -E $PKTGEN_SCRIPT -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -l $LOG_DIR$@.log
elif [ $1 == "256B" ]; then
	sudo -E $PKTGEN_SCRIPT -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -l $LOG_DIR$@.log
elif [ $1 == "512B" ]; then
	sudo -E $PKTGEN_SCRIPT -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -l $LOG_DIR$@.log
elif [ $1 == "1500B" ]; then
	sudo -E $PKTGEN_SCRIPT -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -l $LOG_DIR$@.log
else
	sudo -E $PKTGEN_SCRIPT -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -s 0:$TRACE_DIR -l $LOG_DIR$@.log
fi
