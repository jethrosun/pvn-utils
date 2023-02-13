
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

# We always want to run p2p first
# {"1": "xcdr", "2": "rand1", "3": "rand2", "4": "rand4", "5": "rand3", "6": "tlsv", "7": "p2p", "8": "rdr"}

udf_schedule = ['udf_schedule']
udf_node_list = ['1', '2', '3']
# udf_node_list = ['3']
udf_profile_time = 200
udf_schedule_time = 4000  # only for rand
# udf_schedule_time = 3700

setup = []
zero = '0'

#      RESRC PIN
# -------------------
# udf_nf_list = ['1', '2', '3', '4', '5', '6', '8', '7', ]
# num_of_epoch = 3


#      PROFILE
# -------------------
udf_nf_list = ['1', '2', '3', '4', '5', '6', '7', '8']
profile_num_of_epoch = 1

setup.append([zero, zero, zero])
# for i in ['1', '2', '3']:
#     setup.append([i, zero, zero])
#     setup.append([zero, i, zero])
#     setup.append([zero, zero, i])
#
# combination set
# for i in ['1', '2', '3']:
#     for j in ['1', '2', '3']:
#         for k in ['1', '2', '3']:
#             setup.append([i, j, k])


#      SCHEDULE
# ----------------------
# schedule_list = [ 'rand', 'resrc_pining_23_', 'resrc_pining_32_', 'resrc_pining_41_', 'resrc_pining_122', 'resrc_pining_311' ]
# schedule_list = [ 'resrc_central', 'profile' ]


sched_num_of_epoch = 1

# schedule_list = [ 'rand', 'profile', 'profile_w_rand', 'resrc_central', 'resrc_central_w_cont',
#                  'resrc_pining_23_', 'resrc_pining_32_', 'resrc_pining_41_', 'resrc_pining_122', 'resrc_pining_311' ]
# schedule_list = [ 'profile', 'profile_w_rand', 'resrc_central', 'resrc_central_w_cont']

# batch_list = [
#     '400019_10', '400019_20', '400019_30', '400019_40', '400019_50',
#     '1374946_10', '1374946_20', '1374946_30', '1374946_40', '1374946_50',
#     '664673_10', '664673_20', '664673_30', '664673_40', '664673_50',
# ]

# ----------------------
#       rand
# ----------------------

schedule_list = ['rand']
# batch_list = ['400019_50', '1374946_50', '664673_50', ]
# batch_list = ['1374946_30', '664673_30', '400019_30']
# batch_list = ['400019_40', '1374946_40', '664673_40', ]
# batch_list = ['1374946_20', '664673_20', '400019_20']
# TODO: complete schedule for new model training and scheduling
batch_list = [ '400019_10', '1374946_10', '664673_10',]

# ----------------------------
#       pining
# ----------------------------

# schedule_list = ['resrc_pining_23_', 'resrc_pining_32_', 'resrc_pining_41_', 'resrc_pining_122', 'resrc_pining_311']
# batch_list = ['1374946_30', '664673_30', '400019_30', '400019_50', ]
# batch_list = ['1374946_50', '664673_50', ]

# batch_list = ['400019_40', '1374946_40', '664673_40', '1374946_20', '664673_20', '400019_20']
# TODO: complete schedule for new model

# batch_list = [ '400019_10', '1374946_10', '664673_10',]


# ----------------------------
#       profile vs rc
# ----------------------------


# schedule_list = ['resrc_central']
# batch_list = ['400019_50', '1374946_50', '664673_50',
#               '400019_40', '1374946_40', '664673_40', ]
# batch_list = ['1374946_30', '664673_30', '400019_30']
# batch_list = [ '400019_20', '1374946_20', '664673_20',]
# batch_list = [ '400019_10', '1374946_10', '664673_10',]


# schedule_list = ['profile_w_rand2']
# batch_list = ['1374946_30', '664673_30', '400019_30',
#               '400019_50', '1374946_50', '664673_50',]
# batch_list = [ '400019_40', '1374946_40', '664673_40', ]
# batch_list = [ '400019_20', '1374946_20', '664673_20',]
# batch_list = [ '400019_10', '1374946_10', '664673_10',]


