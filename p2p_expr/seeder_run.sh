#!/bin/bash
set -exuo pipefail

# https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
# http://aria2.github.io/manual/en/html/aria2c.html

# cd ~/data/downloads
# aria2c --seed-ratio=0.0 --listen-port=9000 --bt-enable-lpd --bt-external-ip=10.200.111.125 --enable-peer-exchange -V -d . ~/torrents/*.torrent


cd ~/torrents && qbittorrent-nox *

