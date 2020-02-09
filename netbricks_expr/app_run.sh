#!/bin/bash

#set -x
set -euo pipefail

export RUST_BACKTRACE=full
NF_NAME=pvn-tlsv-re
M_CORE=1

PORT_ONE="0000:01:00.0"
PORT_TWO="0000:01:00.1"

../../build.sh run $NF_NAME -f config_6core.toml
