#!/bin/bash
set -ex

PID=`ps -eaf | grep p2p_run_leecher | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$PID" ]]; then
  echo "killing $PID"
  kill -9 $PID
fi

sudo rm -rf ~/qbt_data
mkdir -p ~/qbt_data
