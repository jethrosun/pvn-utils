#!/bin/bash
set -e


if [ -e .venv ]; then
	echo "Passing, venv exists.."
else
	virtualenv -p /usr/bin/python3 .venv
fi

source .venv/bin/activate
pip3 install -r requirements.txt
deactivate


