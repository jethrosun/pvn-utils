#!/usr/bin/env python

import numpy as np
import json

def gen_rand_number(size, max_val):
    numbers = np.random.choice(range(max_val), size, replace=False)
    # print(np.sort(numbers))
    return np.sort(numbers).tolist()


json_data = {}

# create set of random number for rdr
rdr_setup_list = [5, 10, 20, 40, 80, 100]

json_data['rdr'] = {}
print("Generate random number for rdr setups")
for setup in rdr_setup_list:
    print("Setup:", setup)
    json_data['rdr'][str(setup+1)] = {}
    for x in range(6):
        # print(x, "iteration")
        json_data['rdr'][str(setup+1)][x] = gen_rand_number(setup, 100)


# create set of random number for p2p
p2p_setup_list = [1, 10, 20, 50, 100, 200]

json_data['p2p'] = {}
print("Generate random number for p2p setups")
for setup in p2p_setup_list:
    print("Setup:", setup)
    json_data['p2p'][str(setup+1)] = {}
    for x in range(6):
        # print(x, "iteration")
        json_data['p2p'][str(setup+1)][x] = gen_rand_number(setup, 200)


with open('rand.json', 'w') as outfile:
    json.dump(json_data, outfile)
