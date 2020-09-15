#!/bin/bash
set -ex

P2P_PID=`ps -eaf | grep p2p_run_leecher | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$P2P_PID" ]]; then
  echo "killing $P2P_PID"
  kill -9 $P2P_PID
fi

QBT_PID=`ps -eaf | grep qbittorrent | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$QBT_PID" ]]; then
  echo "killing $QBT_PID"
  kill -9 $QBT_PID
fi


sudo rm -rf ~/qbt_data
mkdir -p ~/qbt_data
