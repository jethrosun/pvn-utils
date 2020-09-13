#!/bin/bash
set -ex

cd $HOME/dev/pvn/utils

screen -S pvn_main -d -m ./pvn_app.py
