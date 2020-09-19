#!/bin/bash
set -ex


P2P_PID=`ps -eaf | grep p2p_run_leecher | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$P2P_PID" ]]; then
  echo "killing $P2P_PID"
  sudo kill -9 $P2P_PID
fi

BT_PID=`ps -eaf | grep deluged | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi


sudo rm -rf /home/jethros/bt_data
