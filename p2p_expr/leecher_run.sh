#!/bin/bash
set -exuo pipefail

# https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
# http://aria2.github.io/manual/en/html/aria2c.html

# -s: how many mirrors to use to download each file, mirrors should be listed in one line
# -j: how many files (lines in the input file) to download simultaneously
# -x: how many streams to use for downloading from each mirror.

cd ~/data/downloads
aria2c -d . -s 5 -j 70 -x 700 ~/torrents/*.torrent
