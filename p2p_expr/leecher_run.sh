#!/bin/bash
set -exuo pipefail

# https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
# http://aria2.github.io/manual/en/html/aria2c.html

cd ~/data/downloads
aria2c ~/torrents/*.torrent
