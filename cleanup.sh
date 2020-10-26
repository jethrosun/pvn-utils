#!/bin/bash

set -e

current_date_time="`date "+%Y-%m-%d--%H-%M-%S"`";
echo $current_date_time;

if [ -e $HOME/netbricks_logs ]; then
	rm -rf $HOME/dev/pvn/utils/data/output_videos
	rm -rf /tmp/*
	mkdir -p $HOME/logs/netbricks_logs--$current_date_time
	mv $HOME/netbricks_logs/ $HOME/logs/netbricks_logs--$current_date_time
	cd $HOME/logs
	tar -cvzf netbricks_logs--$current_date_time.tar.gz  netbricks_logs--$current_date_time
	rm -rf netbricks_logs--$current_date_time
	printf "Moving all netbricks logs to the backup logs\n"
fi
if [ -e $HOME/pktgen_logs ]; then
	mkdir -p $HOME/logs/pktgen_logs--$current_date_time
	mv $HOME/pktgen_logs/ $HOME/logs/pktgen_logs--$current_date_time
	printf "Moving all pktgen logs to the backup logs\n"
fi
# if [ -f $HOME/dev/pvn/utils/*.log ]; then
if ls $HOME/dev/pvn/utils/*.log >/dev/null 2>&1; then
	mkdir -p $HOME/logs/pktgen_logs--$current_date_time
	mv $HOME/dev/pvn/utils/netbricks*.log $HOME/logs/pktgen_logs--$current_date_time
	printf "Moving just the pvn netbricks logs to the backup logs\n"
	mkdir -p $HOME/logs/pktgen_logs--$current_date_time
	mv $HOME/dev/pvn/utils/*.log $HOME/logs/pktgen_logs--$current_date_time
	cd $HOME/logs
	tar -cvzf pktgen_logs--$current_date_time.tar.gz  pktgen_logs--$current_date_time
	rm -rf pktgen_logs--$current_date_time
	printf "Moving just the pvn pktgen logs to the backup logs\n"
else
	printf "nothing to be done?\n"
fi

