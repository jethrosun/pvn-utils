#!/bin/bash
set -ex

sudo rm -rf /home/jethros/dev/pvn/utils/data/output_videos/
mkdir /home/jethros/dev/pvn/utils/data/output_videos/

# we don't need to build every time
cd /home/jethros/dev/pvn/utils/faktory_srv/
# /home/jethros/.cargo/bin/cargo build --release

# sudo /home/jethros/.cargo/bin/cargo run $1 $2 $3

# sudo -u jethros /home/jethros/dev/pvn-utils/faktory_srv/target/release/faktory_srv $1 $2
sudo /home/jethros/dev/pvn/utils/faktory_srv/target/release/faktory_srv $1 $2 $3 > $4
