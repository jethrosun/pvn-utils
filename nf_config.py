
pvn_nf = {
    # nf app
    'app_rdr': ['pvn-rdr-transform-app'],
    'app_xcdr': ['pvn-transcoder-transform-app'],
    'app_tlsv': ['pvn-tlsv-transform-app'],
    'app_p2p-controlled': ['pvn-p2p-transform-app'],

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

    'udf': 'rdr1_p2p1.pcap',
    'udf_profile': 'rdr1_p2p1.pcap',
    'udf_schedule': 'rdr1_p2p1.pcap'
}

rdr_clean_list = [
    'pvn-rdr-transform-app',
    'udf_profile',
    'udf_schedule'
]

p2p_clean_list = [
    'pvn-p2p-transform-app',
    'udf_profile',
    'udf_schedule'
]
xcdr_clean_list = [
    'pvn-transcoder-transform-app',
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
# for i in ['1', '2', '3']:
#     setup.append([i, zero, zero])
#     setup.append([zero, i, zero])
#     setup.append([zero, zero, i])

# combination set
# for i in ['1', '2', '3']:
#     for j in ['1', '2', '3']:
#         for k in ['1', '2', '3']:
#             setup.append([i, j, k])

udf_schedule = ['udf_schedule']

# We always want to run p2p first
# {"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}
udf_node_list = ['1', '2', '3']
udf_profile_time = 200
udf_schedule_time = 3800

# udf_nf_list = ['7', '1', '2', '3', '4', '5', '6', '8']
# num_of_epoch = 3

# profile
# udf_nf_list = ['1', '6', '8']
# udf_nf_list = ['7']
# udf_nf_list = ['7', '1', '2', '3', '4', '5', '6', '8']
udf_nf_list = ['1', '2', '3', '4', '5', '6', '8', '7', ]
num_of_epoch = 3
