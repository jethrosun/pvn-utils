#!/bin/bash
set -ex

# mkdir -p $HOME/dev
# mkdir -p $HOME/data/cargo-target

# rm -rf $HOME/dev/netbricks
# printf "Resetting netbricks\n"
# git clone git@github.com:jethrosun/NetBricks.git -b expr $HOME/dev/netbricks

cd "$HOME/dev/netbricks" || exit
git pull

"$HOME/dev/netbricks/build.sh"
printf "netbricks building done\n"
