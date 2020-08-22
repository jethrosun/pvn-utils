#!/bin/bash
set -ex

# reload config setting
# killall -HUP transmission-da
sudo pkill -HUP transmission-da

# stop and restart daemon
sudo /etc/init.d/transmission-daemon stop
sudo /etc/init.d/transmission-daemon start

sleep 5
