#!/bin/bash
set -ex

cd $HOME/dev/pvn/utils

# screen -S pvn_main -d -m ./pvn_app.py
screen -S pvn_p2p -d -m ./pvn_p2p.py
