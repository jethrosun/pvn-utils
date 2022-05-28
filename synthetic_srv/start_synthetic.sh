#!/bin/bash
set -ex

# cd /home/jethros/dev/pvn/utils/faktory_srv/

sudo /home/jethros/data/cargo-target/release/faktory_srv $1 $2 > $3
