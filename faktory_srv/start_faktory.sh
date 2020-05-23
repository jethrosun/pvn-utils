#!/bin/bash
set -ex

sudo -u jethros rm -rf /home/jethros/dev/pvn-utils/data/output_videos/
mkdir /home/jethros/dev/pvn-utils/data/output_videos/

cargo build --release
sudo -u jethros ./target/release/faktory_srv
