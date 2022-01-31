# def scheduler(raw_tasks):
#     tasks = []
#     for task in raw_tasks:
#         nf_load = {'tlsv': 0, 'rdr': 0, 'xcdr': 0, 'p2p': 0}
#         name = 'co_'
#         nfs = task.split('_')
#         for nf in nfs:
#             nf_name = nf[:-1]
#             nf_load[nf_name] = nf[-1]
#             name += nf_name
#             name += "_"
#         load = [nf_load[nf] for nf in ['tlsv', 'rdr', 'xcdr', 'p2p']]
#         tasks.append({name[:-1]: load})
#     return tasks


#  we have to do some hacking so our other experiemnt config can remain the same
def translate(raw_task):
    name = 'co_'
    # 0 means no load
    nf_load = {'tlsv': 0, 'rdr': 0, 'xcdr': 0, 'p2p': 0}
    nfs = raw_task.split('_')
    for nf in nfs:
        nf_name = nf[:-1]
        # load+6 matches our setup
        nf_load[nf_name] = int(nf[-1]) + 6
        name += nf_name
        name += "_"
    load = [nf_load[nf] for nf in ['tlsv', 'rdr', 'xcdr', 'p2p']]

    return name[:-1], load


def fetch_tlsv_trace(setup):
    return 'pvn_tlsv' + setup + '.pcap'


def fetch_sending_rate(nf):
    # nf
    if nf in [
            pvn_nf[x][0] for x in ['app_rdr', 'app_xcdr', 'app_tlsv', 'app_p2p', 'app_p2p-ext', 'app_p2p-controlled']
    ]:
        sending_rate = 10
        # chain
    elif nf in [
            pvn_nf[x][0]
            for x in ['co_tlsv_rdr', 'co_rdr_p2p', 'co_rdr_xcdr', 'co_tlsv_p2p', 'co_tlsv_xcdr', 'co_xcdr_p2p']
    ]:
        sending_rate = 20
        # coresident
    elif nf in [pvn_nf[x][0] for x in [
            'co_tlsv_rdr_p2p',
            'co_tlsv_xcdr_p2p',
            'co_tlsv_rdr_xcdr',
            'co_rdr_xcdr_p2p',
    ]]:
        sending_rate = 30
    elif nf == pvn_nf['co_tlsv_rdr_xcdr_p2p'][0]:
        sending_rate = 40
    else:
        print("unknown nf:", nf)
        exit()

    return sending_rate


pvn_nf = {
    # nf app
    'app_rdr': ['pvn-rdr-transform-app'],
    'app_xcdr': ['pvn-transcoder-transform-app'],
    'app_tlsv': ['pvn-tlsv-transform-app'],
    'app_p2p': ['pvn-p2p-transform-app'],
    'app_p2p-ext': ['pvn-p2p-transform-app'],
    'app_p2p-controlled': ['pvn-p2p-transform-app'],
    # chain
    'co_tlsv_rdr': ['pvn-tlsv-rdr-coexist-app'],
    'co_rdr_p2p': ['pvn-rdr-p2p-coexist-app'],
    'co_rdr_xcdr': ['pvn-rdr-xcdr-coexist-app'],
    'co_tlsv_p2p': ['pvn-tlsv-p2p-coexist-app'],
    'co_tlsv_xcdr': ['pvn-tlsv-xcdr-coexist-app'],
    'co_xcdr_p2p': ['pvn-xcdr-p2p-coexist-app'],
    # coresident
    'co_tlsv_rdr_p2p': ['pvn-tlsv-rdr-p2p-coexist-app'],
    'co_tlsv_xcdr_p2p': ['pvn-tlsv-p2p-xcdr-coexist-app'],
    'co_tlsv_rdr_xcdr': ['pvn-tlsv-rdr-xcdr-coexist-app'],
    'co_rdr_xcdr_p2p': ['pvn-rdr-xcdr-p2p-coexist-app'],
    'co_tlsv_rdr_xcdr_p2p': ['pvn-tlsv-rdr-p2p-xcdr-coexist-app'],
    # tasks
    'co_rdr': ['pvn-rdr-transform-app'],
    'co_xcdr': ['pvn-transcoder-transform-app'],
    'co_tlsv': ['pvn-tlsv-transform-app'],
    'co_p2p': ['pvn-p2p-transform-app']
}

trace = {
    # nf
    'app_rdr': 'pvn_rdr.pcap',
    'app_xcdr': 'pvn_xcdr.pcap',
    'app_tlsv': 'pvn_tlsv6.pcap',
    'app_p2p': 'pvn_p2p.pcap',
    'app_p2p-ext': 'pvn_p2p.pcap',
    'app_p2p-controlled': 'pvn_p2p.pcap',
    # chain
    'co_tlsv_rdr': 'pvn_rdr_tlsv.pcap',
    'co_rdr_p2p': 'pvn_rdr_p2p.pcap',
    'co_rdr_xcdr': 'pvn_rdr_xcdr.pcap',
    'co_tlsv_p2p': 'pvn_tlsv_p2p.pcap',
    'co_tlsv_xcdr': 'pvn_tlsv_xcdr.pcap',
    'co_xcdr_p2p': 'pvn_xcdr_p2p.pcap',
    # coresident
    'co_tlsv_rdr_p2p': 'pvn_tlsv_rdr_p2p.pcap',
    'co_tlsv_xcdr_p2p': 'pvn_tlsv_p2p_xcdr.pcap',
    'co_tlsv_rdr_xcdr': 'pvn_tlsv_rdr_xcdr.pcap',
    'co_rdr_xcdr_p2p': 'pvn_rdr_xcdr_p2p.pcap',
    'co_tlsv_rdr_xcdr_p2p': 'pvn_tlsv_rdr_p2p_xcdr.pcap',

    # tasks
    #
    # 'tlsv2': 'tlsv2.pcap',
    # 'xcdr2': 'xcdr2.pcap',
    # 'rdr1': 'rdr1.pcap',
    # 'tlsv1': 'tlsv1.pcap',
    # 'xcdr3': 'xcdr3.pcap',
    'tlsv1_rdr2': 'tlsv1_rdr2.pcap',
    'rdr2_xcdr1': 'rdr2_xcdr1.pcap',
    'rdr1_xcdr2': 'rdr1_xcdr2.pcap',
    'tlsv1_rdr1': 'tlsv1_rdr1.pcap',
    'tlsv1_xcdr1': 'tlsv1_xcdr1.pcap',
    'tlsv2_xcdr1': 'tlsv2_xcdr1.pcap',
    'tlsv1_rdr1_xcdr2': 'tlsv1_rdr1_xcdr2.pcap',
    'tlsv1_rdr2_xcdr3': 'tlsv1_rdr2_xcdr3.pcap',
    # final list
    'xcdr1': 'xcdr1.pcap',
    'rdr1_xcdr1': 'rdr1_xcdr1.pcap',
    'tlsv1_rdr1_xcdr1': 'tlsv1_rdr1_xcdr1.pcap',
    'tlsv1_rdr2': 'tlsv1_rdr2.pcap',
    'tlsv2_xcdr3': 'tlsv2_xcdr3.pcap',
    'rdr2': 'rdr2.pcap',

    # p2p
    # 'p2p2': 'p2p2.pcap',
    'rdr1_p2p1': 'rdr1_p2p1.pcap',
    'tlsv1_p2p1': 'tlsv1_p2p1.pcap',
    'xcdr1_p2p1': 'xcdr1_p2p1.pcap',
    'rdr2_xcdr1_p2p1': 'rdr2_xcdr1_p2p1.pcap',
    'tlsv1_rdr1_p2p1': 'tlsv1_rdr1_p2p1.pcap',
    'tlsv1_xcdr1_p2p1': 'tlsv1_xcdr1_p2p1.pcap',
    'tlsv1_rdr1_xcdr3_p2p1': 'tlsv1_rdr1_xcdr3_p2p1.pcap',
    # final list
    'p2p1': 'p2p1.pcap',
    'p2p3': 'p2p3.pcap',
    'rdr1_xcdr3_p2p1': 'rdr1_xcdr3_p2p1.pcap',
    'tlsv1_xcdr1_p2p2': 'tlsv1_xcdr1_p2p2.pcap',
    'tlsv1_xcdr1_p2p1': 'tlsv1_xcdr1_p2p1.pcap',
    'tlsv2_p2p1': 'tlsv2_p2p1.pcap',
    'xcdr1_p2p1': 'xcdr1_p2p1.pcap',
    'tlsv1_rdr1_xcdr1_p2p2': 'tlsv1_rdr1_xcdr1_p2p2.pcap',
    'rdr1_xcdr1_p2p1': 'rdr1_xcdr1_p2p1.pcap',
    'xcdr1_p2p2': 'xcdr1_p2p2.pcap',
    'rdr2_p2p1': 'rdr2_p2p1.pcap',
    'tlsv1_rdr1_p2p1': 'tlsv1_rdr1_p2p1.pcap',
    'rdr1_xcdr2_p2p1': 'rdr1_xcdr2_p2p1.pcap',
    'tlsv1_xcdr2_p2p1': 'tlsv1_xcdr2_p2p1.pcap',
    'tlsv1_rdr1_xcdr1_p2p1': 'tlsv1_rdr1_xcdr1_p2p1.pcap',
    'tlsv1_xcdr2_p2p2': 'tlsv1_xcdr2_p2p2.pcap',
    'tlsv2_rdr1_xcdr1_p2p1': 'tlsv2_rdr1_xcdr1_p2p1.pcap',
    'rdr1_p2p1': 'rdr1_p2p1.pcap'
}

# # nf app
# 'pvn-rdr-transform-app',
# 'pvn-transcoder-transform-app',
# 'pvn-tlsv-transform-app',
# 'pvn-p2p-transform-app',
# 'pvn-p2p-transform-app',
# 'pvn-p2p-transform-app',
# # chain
# 'pvn-tlsv-rdr-coexist-app',
# 'pvn-rdr-p2p-coexist-app',
# 'pvn-rdr-xcdr-coexist-app',
# 'pvn-tlsv-p2p-coexist-app',
# 'pvn-tlsv-xcdr-coexist-app',
# 'pvn-xcdr-p2p-coexist-app',
# # coresident
# 'pvn-tlsv-rdr-p2p-coexist-app',
# 'pvn-tlsv-p2p-xcdr-coexist-app',
# 'pvn-tlsv-rdr-xcdr-coexist-app',
# 'pvn-rdr-xcdr-p2p-coexist-app',
# 'pvn-tlsv-rdr-p2p-xcdr-coexist-app',

rdr_clean_list = [
    'pvn-rdr-transform-app',
    # chain
    'pvn-tlsv-rdr-coexist-app',
    'pvn-rdr-p2p-coexist-app',
    'pvn-rdr-xcdr-coexist-app',
    # coresident
    'pvn-tlsv-rdr-p2p-coexist-app',
    'pvn-tlsv-rdr-xcdr-coexist-app',
    'pvn-rdr-xcdr-p2p-coexist-app',
    'pvn-tlsv-rdr-p2p-xcdr-coexist-app',
]

p2p_clean_list = [
    'pvn-p2p-transform-app',
    # chain
    'pvn-rdr-p2p-coexist-app',
    'pvn-tlsv-p2p-coexist-app',
    'pvn-xcdr-p2p-coexist-app',
    # coresident
    'pvn-tlsv-rdr-p2p-coexist-app',
    'pvn-tlsv-p2p-xcdr-coexist-app',
    'pvn-rdr-xcdr-p2p-coexist-app',
    'pvn-tlsv-rdr-p2p-xcdr-coexist-app',
]
xcdr_clean_list = [
    'pvn-transcoder-transform-app',
    # chain
    'pvn-rdr-xcdr-coexist-app',
    'pvn-tlsv-xcdr-coexist-app',
    'pvn-xcdr-p2p-coexist-app',
    # coresident
    'pvn-tlsv-p2p-xcdr-coexist-app',
    'pvn-tlsv-rdr-xcdr-coexist-app',
    'pvn-rdr-xcdr-p2p-coexist-app',
    'pvn-tlsv-rdr-p2p-xcdr-coexist-app',
]

# expr_nf_list = [
#     'pvn-tlsv-transform-app',
#     'pvn-p2p-transform-app',
#     'pvn-rdr-transform-app',
#     'pvn-transcoder-transform-app',
# ]
# p2p_nf_list = ['pvn-p2p-transform-app', 'pvn-p2p-groupby-app']
# pvn_chain_list = ['pvn-tlsv-rdr-coexist-app']
# p2p_nf_list = ['pvn-p2p-transform-app', 'pvn-p2p-groupby-app']
# p2p_chain_list = [
#     'pvn-tlsv-p2p-coexist-app', 'pvn-rdr-p2p-coexist-app',
#     'pvn-xcdr-p2p-coexist-app'
# ]
# xcdr_nf_list = ['pvn-transcoder-transform-app', 'pvn-transcoder-groupby-app']
# xcdr_chain_list = ['pvn-rdr-xcdr-coexist-app', 'pvn-tlsv-xcdr-coexist-app']
# xcdr_p2p_chain_list = ['pvn-xcdr-p2p-coexist-app']
# p2p_ext_list = ['11', '12', '13', '14', '15', '16', '17', '18', '19', '20']

########################################################################
#
# Experiment defined values:
#
########################################################################
# expr_wait_time = 300  # only for RDR latency
expr_wait_time = 250
# expr is 3 min/180 sec
# expr_wait_time = 220
xcdr_port_base = 7418
batch = 1

# app
rdr_xcdr_tlsv = ['app_rdr', 'app_xcdr', 'app_tlsv']
rdr_xcdr = ['app_rdr', 'app_xcdr']
tlsv = ['app_tlsv']
xcdr = ['app_xcdr']
rdr = ['app_rdr']
p2p_controlled = ['app_p2p-controlled']

# coresident
non_p2p_co = ['co_tlsv_rdr', 'co_rdr_xcdr', 'co_tlsv_xcdr', 'co_tlsv_rdr_xcdr']
p2p_co = [
    'co_rdr_p2p', 'co_tlsv_p2p', 'co_xcdr_p2p', 'co_tlsv_rdr_p2p', 'co_tlsv_xcdr_p2p', 'co_rdr_xcdr_p2p',
    'co_tlsv_rdr_xcdr_p2p'
]
# p2p_co = ['co_tlsv_rdr_xcdr_p2p']
# set_list = ['1', '2', '3', '4', '5', '6']
# num_of_epoch = 5
# p2p_num_of_epoch = 5

set_list = ['7', '8', '9', '10', '11', '12', '13', '14', '15', '16']
num_of_epoch = 1
p2p_num_of_epoch = 1

# only for testing
# p2p_co = ['co_tlsv_rdr_p2p']
# set_list = ['6']
# num_of_epoch = 1
# p2p_num_of_epoch = 1

# ----------------------------------------
#           task running
#
# ----------------------------------------
raw_tasks = [
    'tlsv2_rdr1_xcdr2', 'tlsv1_rdr1_xcdr2', 'tlsv1_rdr1_xcdr3', 'rdr2_xcdr3', 'tlsv1_xcdr1', 'tlsv2_rdr1_xcdr1',
    'tlsv1_rdr1_xcdr1', 'tlsv3_rdr1_xcdr1', 'tlsv1_rdr2_xcdr1', 'tlsv2', 'tlsv2_rdr3_xcdr1', 'tlsv3', 'xcdr2',
    'tlsv2_xcdr2', 'rdr2_xcdr2', 'rdr3', 'tlsv2_rdr6', 'rdr5', 'rdr2', 'xcdr3', 'tlsv2_xcdr3', 'tlsv2_rdr2_xcdr1',
    'tlsv3_xcdr2', 'tlsv1_xcdr4', 'tlsv1_rdr2_xcdr2', 'tlsv4_rdr1', 'tlsv3_rdr2', 'tlsv1_rdr3_xcdr1', 'tlsv2_rdr3'
]

raw_p2p_tasks = [
    'tlsv1_rdr1_xcdr3_p2p1', 'tlsv3_xcdr1_p2p1', 'tlsv1_rdr2_xcdr5_p2p1', 'tlsv2_rdr1_xcdr3_p2p1', 'tlsv1_rdr1_p2p2',
    'tlsv1_rdr1_xcdr1_p2p1', 'tlsv2_rdr1_xcdr3_p2p2', 'tlsv2_rdr2_xcdr2_p2p2', 'tlsv1_xcdr1_p2p1',
    'tlsv1_rdr3_xcdr2_p2p1', 'tlsv3_p2p1', 'tlsv2_rdr2_xcdr1_p2p1', 'tlsv2_xcdr2_p2p1', 'tlsv4_rdr2_xcdr1_p2p1',
    'tlsv1_rdr1_p2p1', 'tlsv2_rdr3_xcdr1_p2p1', 'tlsv3_rdr1_xcdr1_p2p1', 'tlsv2_xcdr1_p2p1', 'tlsv3_rdr1_p2p1',
    'tlsv4_xcdr1_p2p2', 'xcdr2_p2p1', 'tlsv1_rdr2_p2p2', 'tlsv1_xcdr1_p2p2', 'tlsv2_rdr2_xcdr1_p2p2',
    'tlsv2_xcdr1_p2p2', 'rdr2_xcdr2_p2p3', 'tlsv1_rdr1_xcdr2_p2p2', 'tlsv2_rdr2_xcdr2_p2p1', 'rdr1_xcdr2_p2p1',
    'tlsv1_rdr2_xcdr2_p2p2', 'tlsv2_rdr1_xcdr3_p2p3', 'tlsv1_rdr3_p2p1', 'rdr3_xcdr1_p2p1', 'rdr1_xcdr1_p2p2',
    'tlsv2_rdr5_p2p1', 'rdr3_xcdr1_p2p2', 'p2p1', 'tlsv2_rdr3_p2p1', 'tlsv3_rdr1_xcdr1_p2p2', 'rdr1_p2p2',
    'tlsv3_rdr2_p2p3', 'tlsv2_rdr2_xcdr2_p2p3', 'tlsv2_p2p1', 'tlsv3_xcdr4_p2p1', 'rdr1_xcdr1_p2p1',
    'tlsv1_rdr1_xcdr4_p2p1', 'tlsv2_p2p2', 'tlsv2_xcdr1_p2p3', 'tlsv1_xcdr2_p2p1', 'tlsv1_rdr2_xcdr1_p2p2',
    'tlsv1_rdr1_xcdr1_p2p2', 'tlsv1_rdr1_p2p4', 'tlsv1_rdr2_xcdr1_p2p1', 'rdr1_xcdr3_p2p1', 'tlsv1_rdr1_xcdr2_p2p1',
    'rdr3_p2p2', 'tlsv2_rdr1_xcdr1_p2p1', 'tlsv2_rdr2_p2p1', 'tlsv3_p2p2', 'tlsv1_xcdr1_p2p3', 'tlsv1_xcdr2_p2p2',
    'rdr1_p2p4', 'tlsv2_rdr1_p2p2', 'rdr4_p2p1', 'rdr2_xcdr1_p2p2', 'tlsv1_xcdr3_p2p1', 'rdr1_xcdr2_p2p2',
    'rdr1_xcdr1_p2p3'
]
