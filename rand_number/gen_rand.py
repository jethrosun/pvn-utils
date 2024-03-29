#!/usr/bin/env python

import json

import numpy as np


def gen_rand_number(size, max_val):
    numbers = np.random.choice(range(max_val), size, replace=False)
    # print(np.sort(numbers))
    return np.sort(numbers).tolist()


json_data = {}

# create set of random number for rdr
rdr_setup_list = [5, 10, 20, 40, 80, 100, 30, 50, 60, 70, 90]

json_data['rdr'] = {}
print("Generate random number for rdr setups")
for setup in rdr_setup_list:
    print("Setup:", setup)
    json_data['rdr'][str(setup)] = {}
    for x in range(11):
        # print(x, "iteration")
        json_data['rdr'][str(setup)][x] = gen_rand_number(setup, 100)

# create set of random number for p2p
p2p_setup_list = [1, 10, 20, 50, 100, 200]

json_data['p2p'] = {}
print("Generate random number for p2p setups")
for setup in p2p_setup_list:
    print("Setup:", setup)
    json_data['p2p'][str(setup)] = {}
    for x in range(11):
        # print(x, "iteration")
        json_data['p2p'][str(setup)][x] = gen_rand_number(setup, 200)

# create set of random number for p2p
# p2p_controlled_setup_list = [1, 2, 4, 6, 8, 10]
p2p_controlled_setup_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

json_data['p2p_controlled'] = {}
print("Generate random number for p2p controlled setups")
for setup in p2p_controlled_setup_list:
    print("Setup:", setup)
    json_data['p2p_controlled'][str(setup)] = {}
    for x in range(11):
        # print(x, "iteration")
        json_data['p2p_controlled'][str(setup)][x] = gen_rand_number(setup, 10)
        # print(json_data['p2p_controlled'][str(setup)][x])

with open('rand.json', 'w') as outfile:
    json.dump(json_data, outfile)
