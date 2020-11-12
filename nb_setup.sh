#!/bin/bash
set -ex

cd "$HOME/dev/pvn/utils" || { cd "$HOME/dev/pvn/"; git clone git@github.com:jethrosun/pvn-utils utils; cd "$HOME/dev/pvn/utils" }
git pull

cd "$HOME/dev/netbricks" || { cd "$HOME/dev/"; git clone git@github.com:jethrosun/NetBricks.git -b expr netbricks; cd "$HOME/dev/netbricks" }
git pull

"$HOME/dev/netbricks/build.sh"
printf "netbricks building done\n"
