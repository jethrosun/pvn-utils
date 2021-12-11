#!/usr/bin/env python3

import random

nf_list = ['tlsv', 'rdr', 'xcdr', 'p2p']

nf_workload = []
for i in range(10):
    nf_workload.append(random.choice(nf_list))
print("nf workload\n", nf_workload)

ordered_runs = {}
for i in range(5):
    random.shuffle(nf_workload)
    ordered_runs[i] = nf_workload
print("ordered runs\n", ordered_runs)


def get_nodes(num_of_nodes):
    buckets = {}
    for i in range(num_of_nodes):
        buckets[i] = []
    return buckets


def find_least_load_node(nodes):
    least_load = -1
    least_load_idx = -1
    for idx in nodes:
        if len(nodes[idx]) == 0:
            return idx
        elif least_load > len(nodes[idx]):
            least_load = len(nodes[idx])
            least_load_idx = idx
        else:
            if least_load == -1:
                least_load = len(nodes[idx])
                least_load_idx = idx
    return least_load_idx


def sort_node_workload(nodes):
    workload = {}
    for idx in nodes.keys():  #
        node_workload = {}
        nf_list = nodes[idx]
        for x in nf_list:
            if x not in node_workload:
                node_workload[x] = 1
            else:
                node_workload[x] += 1
        workload["node" + str(idx)] = node_workload

    return workload


################################################################
#
##        Placement algo
#
################################################################


def rand_placement(num_of_nodes, ordered_runs):
    workload = {}
    for i in range(5):
        nf_workload = ordered_runs[i]
        nodes = get_nodes(num_of_nodes)
        for nf in nf_workload:
            bucket = random.choice([x for x in range(3)])
            nodes[bucket].append(nf)
        workload["iter"+str(i)] = sort_node_workload(nodes)
    return workload


nodes = rand_placement(3, ordered_runs)
print("rand placement:\n", nodes)


def least_load_placement(num_of_nodes, ordered_runs):
    workload = {}
    for i in range(5):
        nf_workload = ordered_runs[i]
        nodes = get_nodes(num_of_nodes)
        for nf in nf_workload:
            idx = find_least_load_node(nodes)
            nodes[idx].append(nf)
        workload["iter"+str(i)] = sort_node_workload(nodes)
    return workload


nodes = least_load_placement(3, ordered_runs)
print("least load placement:\n", nodes)


def fancy_placement(num_of_nodes, nf_workload):
    nodes = get_nodes(num_of_nodes)
