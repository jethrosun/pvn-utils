#!/bin/bash
set -ex

printf "Getting netbricks "
mkdir -p $HOME/dev
rm -rf $HOME/dev/netbricks
git clone git@github.com:jethrosun/NetBricks.git -b expr $HOME/dev/netbricks
$HOME/dev/netbricks/build.sh
printf "netbricks building done"
