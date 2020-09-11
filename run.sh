#!/bin/bash
set -ex

screen -S pvn_main -dm bash -c './pvn_app.py'
