#!/bin/bash
set -ex

if [ $HOSTNAME == "tuco" ]; then

	printf "Getting netbricks "
	mkdir -p ~/dev
	rm -rf ~/dev/netbricks
	git clone https://github.com/jethrosun/NetBricks -b expr ~/dev/netbricks
	cd ~/dev/netbricks
	./build.sh
	printf "netbricks building done"

	cd ~/dev/netbricks/scripts
	sudo ./bind-xl710.sh

	cd ~/dev/netbricks/scripts/tuning
	sudo ./energy.sh

	cd ~/dev/pvn-utils
	git pull
	sudo ~/dev/pvn-utils/cleanup.sh
	~/dev/pvn-utils/setup.sh
	printf "pvn utils done"


elif [ $HOSTNAME == "saul" ]; then

	printf "Getting netbricks "

	mkdir -p ~/dev
	rm -rf ~/dev/netbricks
	git clone https://github.com/jethrosun/NetBricks -b expr ~/dev/netbricks
	cd ~/dev/netbricks
	./build.sh
	printf "netbricks building done"

	cd ~/dev/netbricks/scripts
	sudo ~/dev/netbricks/scripts/bind-xl710.sh

	cd ~/dev/netbricks/scripts/tuning
	sudo ~/dev/netbricks/scripts/tuning/energy.sh

	cd ~/dev/pvn-utils
	git pull
	sudo ~/dev/pvn-utils/cleanup.sh
	~/dev/pvn-utils/setup.sh
	printf "pvn utils done"

fi
