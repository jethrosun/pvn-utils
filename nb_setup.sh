#!/bin/bash
set -ex

# pull our code first
if [ -e "$HOME/dev/pvn/utils" ]; then
	cd "$HOME/dev/pvn/utils"
	git pull
else
	cd "$HOME/dev/pvn/"; git clone git@github.com:jethrosun/pvn-utils utils;
fi

# always remove and re-clone NetBricks
if [ -e "$HOME/dev/netbricks" ]; then
	cd "$HOME/dev/netbricks"
	git pull
else
	cd "$HOME/dev/"; git clone git@github.com:jethrosun/NetBricks.git -b 0.3.1 netbricks;
fi


"$HOME/dev/netbricks/build.sh"
printf "netbricks building done\n"
