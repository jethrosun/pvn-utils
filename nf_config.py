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
            pvn_nf[x][0] for x in
        ['chain_tlsv_rdr', 'chain_rdr_p2p', 'chain_rdr_xcdr', 'chain_tlsv_p2p', 'chain_tlsv_xcdr', 'chain_xcdr_p2p']
    ]:
        sending_rate = 20
        # coresident
    elif nf in [pvn_nf[x][0] for x in [
            'co_tlsv_rdr_p2p',
            'co_tlsv_p2p_xcdr',
            'co_tlsv_rdr_xcdr',
            'co_rdr_xcdr_p2p',
    ]]:
        sending_rate = 30
    elif nf == pvn_nf['co_tlsv_rdr_p2p_xcdr'][0]:
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
    'chain_tlsv_rdr': ['pvn-tlsv-rdr-coexist-app'],
    'chain_rdr_p2p': ['pvn-rdr-p2p-coexist-app'],
    'chain_rdr_xcdr': ['pvn-rdr-xcdr-coexist-app'],
    'chain_tlsv_p2p': ['pvn-tlsv-p2p-coexist-app'],
    'chain_tlsv_xcdr': ['pvn-tlsv-xcdr-coexist-app'],
    'chain_xcdr_p2p': ['pvn-xcdr-p2p-coexist-app'],
    # coresident
    'co_tlsv_rdr_p2p': ['pvn-tlsv-rdr-p2p-coexist-app'],
    'co_tlsv_p2p_xcdr': ['pvn-tlsv-p2p-xcdr-coexist-app'],
    'co_tlsv_rdr_xcdr': ['pvn-tlsv-rdr-xcdr-coexist-app'],
    'co_rdr_xcdr_p2p': ['pvn-rdr-xcdr-p2p-coexist-app'],
    'co_tlsv_rdr_p2p_xcdr': ['pvn-tlsv-rdr-p2p-xcdr-coexist-app'],
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
    'chain_tlsv_rdr': 'pvn_rdr_tlsv.pcap',
    'chain_rdr_p2p': 'pvn_rdr_p2p.pcap',
    'chain_rdr_xcdr': 'pvn_rdr_xcdr.pcap',
    'chain_tlsv_p2p': 'pvn_tlsv_p2p.pcap',
    'chain_tlsv_xcdr': 'pvn_tlsv_xcdr.pcap',
    'chain_xcdr_p2p': 'pvn_xcdr_p2p.pcap',
    # coresident
    'co_tlsv_rdr_p2p': 'pvn_tlsv_rdr_p2p.pcap',
    'co_tlsv_p2p_xcdr': 'pvn_tlsv_p2p_xcdr.pcap',
    'co_tlsv_rdr_xcdr': 'pvn_tlsv_rdr_xcdr.pcap',
    'co_rdr_xcdr_p2p': 'pvn_rdr_xcdr_p2p.pcap',
    'co_tlsv_rdr_p2p_xcdr': 'pvn_tlsv_rdr_p2p_xcdr.pcap',
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
# expr_wait_time = 300  # RDR?
expr_wait_time = 250  # RDR?
# expr is 3 min/180 sec
# expr_wait_time = 220
xcdr_port_base = 7418
batch = 1

# app
rdr_xcdr_tlsv = ['app_rdr', 'app_xcdr', 'app_tlsv']
p2p_controlled = ['app_p2p-controlled']

# coresident
p2p_co = [
    # 'chain_rdr_p2p', 'chain_tlsv_p2p', 'chain_xcdr_p2p',
    # 'co_tlsv_rdr_p2p',
    # 'co_tlsv_p2p_xcdr',
    'co_rdr_xcdr_p2p',
    'co_tlsv_rdr_p2p_xcdr'
]

non_p2p_co = ['chain_tlsv_rdr', 'chain_rdr_xcdr', 'chain_tlsv_xcdr', 'co_tlsv_rdr_xcdr']

set_list = ['1', '2', '3', '4', '5', '6']
num_of_epoch = 3
p2p_num_of_epoch = 5

# set_list = ['6']
# num_of_epoch = 1
# p2p_num_of_epoch = 1
