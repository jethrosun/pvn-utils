#!/bin/bash
set -e

if [ $HOSTNAME == "tuco" ]; then

	if [ -e $HOME/dev/netbricks/experiments ]; then
		printf "netbricks setup is alredy done"
	else
		ln -s $HOME/dev/pvn/utils/netbricks_expr $HOME/dev/netbricks/experiments
		printf "netbricks setup finished"
	fi

elif [ $HOSTNAME == "saul" ]; then

	if [ -e $HOME/dev/pktgen-dpdk/experiments ]; then
		printf "pktgen setup is already done"
	else
		ln -s $HOME/dev/pvn/utils/pktgen_expr $HOME/dev/pktgen-dpdk/experiments
	fi

	if [ -e .venv ]; then
		echo "Passing, venv exists.."
	else
		virtualenv -p /usr/bin/python3 .venv
	fi

	source .venv/bin/activate
	pip3 install -r requirements.txt
	deactivate

	printf "pktgen setup finished"
fi
