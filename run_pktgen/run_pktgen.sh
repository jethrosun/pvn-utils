#!/bin/bash

PKTGEN_SCRIPT=$HOME/dev/pktgen-dpdk/app/x86_64-native-linuxapp-gcc/pktgen
# FIXME
TRACE_DIR=$HOME/traces/huge-trace-only-tcp.pcap

echo $@

# 382 M
# sudo -E app/x86_64-native-linuxapp-gcc/pktgen -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -s 0:large-traces/huge-trace.pcap

# Only TCP packet
sudo -E $PKTGEN_SCRIPT -l 0-4 -n 3 -- -P -N -T -m "[1:3].0, [2:4].1"  -s 0:$TRACE_DIR

