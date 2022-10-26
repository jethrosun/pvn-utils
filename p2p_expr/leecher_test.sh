#!/bin/bash
set -ex

# run p2p builder in leecher branch
echo "Run P2P builder in leecher mode"

echo "Starting up now ..."
nohup deluged -c /home/jethros/bt_data/config

# need to run bin directly
cd ~/dev/pvn/p2p-builder/
cargo r --release 664673 rand
