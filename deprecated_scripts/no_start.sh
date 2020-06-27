#!/bin/bash

set -ex

current_date_time="`date "+%Y-%m-%d--%H:%M:%S"`";
echo $current_date_time;

if [ -e $HOME/netbricks_logs ]; then
	mkdir -p $HOME/logs/netbricks_logs/$current_date_time
	mv $HOME/netbricks_logs/ $HOME/logs/netbricks_logs/$current_date_time
	printf "Moving all netbricks logs to the backup logs\n"
elif [ -e $HOME/pktgen_logs ]; then
	mkdir -p $HOME/logs/pktgen_logs/$current_date_time
	mv $HOME/pktgen_logs/ $HOME/logs/pktgen_logs/$current_date_time
	printf "Moving all pktgen logs to the backup logs\n"
elif [ -e $HOME/dev/pvn-utils/netbricks.log ]; then
	mkdir -p $HOME/logs/pktgen_logs/$current_date_time
	mv $HOME/dev/pvn-utils/netbricks.log $HOME/logs/pktgen_logs/$current_date_time
	printf "Moving just the pvn netbricks logs to the backup logs\n"
elif [ -e $HOME/dev/pvn-utils/pktgen.log ]; then
	mkdir -p $HOME/logs/pktgen_logs/$current_date_time
	mv $HOME/dev/pvn-utils/pktgen.log $HOME/logs/pktgen_logs/$current_date_time
	printf "Moving just the pvn pktgen logs to the backup logs\n"
else
	printf "nothing to be done?"
fi

source $HOME/dev/pvn-utils/.venv/bin/activate
printf "Start running experiments..."
./run_expr.py
deactivate
