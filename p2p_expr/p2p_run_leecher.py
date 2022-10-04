#!/usr/bin/env python3

import sys
import json
import subprocess

setup = sys.argv[1]
iteration = sys.argv[2]

# rand_seed_path = "/home/jethros/dev/pvn/utils/rand_number/rand.json"
fp = "/home/jethros/dev/pvn/utils/rand_number/rand.json"

# load json
# fp = lp.AGG_PATH + "app_rdr.json"

with open(fp, 'r') as f:
    # read the data
    data = f.read()
    # then load it using json.loads()
    json_data = json.loads(data)

imgs = json_data['p2p_controlled'][setup][iteration]

#  "add /home/jethros/dev/pvn/utils/workloads/torrent_files/p2p_image_${args[$c]}.img.torrent"
for x in imgs:
    torrent_path = "add /home/jethros/dev/pvn/utils/workloads/torrent_files/p2p_image_" + str(x + 1) + ".img.torrent"
    print(torrent_path)
    subprocess.run(["deluge-console", "-c", "/home/jethros/bt_data/config", torrent_path])
