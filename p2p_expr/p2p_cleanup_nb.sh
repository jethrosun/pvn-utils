#!/bin/bash
set -ex


BT_PID=`ps -eaf | grep deluged | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi

BT_PID=`ps -eaf | grep deluge-gtk | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi

BT_PID=`ps -eaf | grep deluge-web | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi

BT_PID=`ps -eaf | grep deluged | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi

BT_PID=`ps -eaf | grep deluge-gtk | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi

BT_PID=`ps -eaf | grep deluge-web | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$BT_PID" ]]; then
  echo "killing $BT_PID"
  sudo kill -9 $BT_PID
fi


sudo rm -rf /data/bt
sudo rm -rf /data/tmp
sudo rm -rf /home/jethros/Downloads

