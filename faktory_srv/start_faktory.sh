#!/bin/bash
set -ex

sudo rm -rf /home/jethros/dev/pvn/utils/data/output_videos/
mkdir /home/jethros/dev/pvn/utils/data/output_videos/

sudo rm -rf /data/bt

sudo rm -rf /data/output_videos/
mkdir /data/output_videos/


# we don't need to build every time
cd /home/jethros/dev/pvn/utils/faktory_srv/
# /home/jethros/.cargo/bin/cargo build --release

# sudo /home/jethros/.cargo/bin/cargo run $1 $2 $3

sudo taskset -c $3 /home/jethros/data/cargo-target/release/faktory_srv $1 $2 > $4
