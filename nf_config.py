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
    sending_rate = 0
    nfs = raw_task.split('_')
    for nf in nfs:
        nf_name = nf[:-1]
        # load+6 matches our setup
        nf_load[nf_name] = int(nf[-1]) + 6
        sending_rate += int(nf[-1])
        name += nf_name
        name += "_"
    load = [nf_load[nf] for nf in ['tlsv', 'rdr', 'xcdr', 'p2p']]

    return name[:-1], load, sending_rate*10


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
    'co_p2p': ['pvn-p2p-transform-app'],
    'udf': ['udf-schedule'],
    'udf_schedule': ['udf-schedule'],
    'udf_profile': ['udf-profile']
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
    'rdr1_p2p1': 'rdr1_p2p1.pcap',

    'udf': 'rdr1_p2p1.pcap',
    'udf_profile': 'rdr1_p2p1.pcap',
    'udf_schedule': 'rdr1_p2p1.pcap'
}

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
    'udf_profile',
    'udf_schedule'
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
    'udf_profile',
    'udf_schedule'
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
    'udf_profile',
    'udf_schedule'
]

########################################################################
#
# Experiment defined values:
#
########################################################################


setup = []
zero = '0'
# in isolation
setup.append([zero, zero, zero])
for i in ['1', '2', '3']:
    setup.append([i, zero, zero])
    setup.append([zero, i, zero])
    setup.append([zero, zero, i])

# No need, we only want to look at contention in isolation
# combination set
# for i in ['1', '2', '3']:
#     for j in ['1', '2', '3']:
#         for k in ['1', '2', '3']:
#             setup.append([i, j, k])

udf_schedule = ['udf_schedule']
udf_nf_list = ['1', '2', '3', '4', '5', '6', '7', '8']
num_of_epoch = 3
udf_expr_wait_time = 200
