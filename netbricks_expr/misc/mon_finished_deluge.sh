#!/bin/bash
set -ex

deluge-console -c ~/bt_data/config "info --sort-reverse=file_progress"
