#!/bin/bash
set -ex

sudo service transmission-daemon stop
sudo service transmission-daemon start
