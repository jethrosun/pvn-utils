#!/bin/bash
set -ex

if [ -e "$HOME/dev/pvn/utils" ]; then
	cd "$HOME/dev/pvn/utils"
	git pull
else
	cd "$HOME/dev/pvn/"; git clone git@github.com:jethrosun/pvn-utils utils;
fi

if [ -e "$HOME/dev/netbricks" ]; then
	cd "$HOME/dev/netbricks"
	git pull
else
	cd "$HOME/dev/"; git clone git@github.com:jethrosun/NetBricks.git -b expr netbricks;
fi

"$HOME/dev/netbricks/build.sh"
printf "netbricks building done\n"
