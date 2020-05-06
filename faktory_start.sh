#!/bin/bash
set -ex

docker run --rm -it -v faktory-data:/var/lib/faktory -e "FAKTORY_PASSWORD=some_password" -p 127.0.0.1:7419:7419 -p 127.0.0.1:7420:7420 contribsys/faktory:latest /faktory -b :7419 -w :7420 -e production
