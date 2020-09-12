#!/bin/bash
set -ex

mkdir -p $HOME/dev
rm -rf $HOME/dev/netbricks
printf "Resetting netbricks\n"
git clone git@github.com:jethrosun/NetBricks.git -b expr $HOME/dev/netbricks
$HOME/dev/netbricks/build.sh
printf "netbricks building done\n"
