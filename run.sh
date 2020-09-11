#!/bin/bash
set -ex

screen -S pvn_main -dm bash -c 'cd $HOME/dev/pvn/utils; ./pvn_app.py &'
