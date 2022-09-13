def fetch_tlsv_trace(setup):
    return 'pvn_tlsv' + setup + '.pcap'


pvn_nf = {
    'app_rdr': 'pvn-rdr-transform-app',
    'app_xcdr': 'pvn-transcoder-transform-app',
    'app_tlsv': 'pvn-tlsv-transform-app',
    'app_p2p': 'pvn-p2p-transform-app',
    'app_p2p-ext': 'pvn-p2p-transform-app',
    'app_p2p-controlled': 'pvn-p2p-transform-app',
    'zcsi-nat': 'zcsi-nat',
    "zcsi-lpm": "zcsi-lpm",
    "zcsi-maglev": "zcsi-maglev",
    "zcsi-aclfw": "zcsi-aclfw"
}

pvn_trace = {
    # 'app_rdr': 'pvn_rdr.pcap',
    # 'app_xcdr': 'pvn_xcdr.pcap',
    # 'app_p2p': 'pvn_p2p.pcap',
    # 'app_p2p-ext': 'pvn_p2p.pcap',
    # 'app_p2p-controlled': 'pvn_p2p.pcap',
    'app_tlsv': ['pvn_tlsv6.pcap', 'ictf2010-0-re.pcap', '64B', '128B', '256B', '512B', '1500B'],
    'zcsi-nat': ['pvn_tlsv6.pcap', 'ictf2010-0-re.pcap', '64B', '128B', '256B', '512B', '1500B'],
    "zcsi-lpm": ['pvn_tlsv6.pcap', 'ictf2010-0-re.pcap', '64B', '128B', '256B', '512B', '1500B'],
    "zcsi-maglev": ['pvn_tlsv6.pcap', 'ictf2010-0-re.pcap', '64B', '128B', '256B', '512B', '1500B'],
    "zcsi-aclfw": ['pvn_tlsv6.pcap', 'ictf2010-0-re.pcap', '64B', '128B', '256B', '512B', '1500B']
}

setup = []
zero = '0'
# in isolation
setup.append([zero, zero, zero])
for i in ['1', '2', '3']:
    setup.append([i, zero, zero])
    setup.append([zero, i, zero])
    setup.append([zero, zero, i])

# combination set
# for i in ['1', '2', '3']:
#     for j in ['1', '2', '3']:
#         for k in ['1', '2', '3']:
#             setup.append([i, j, k])

# num_of_epoch = 5
# num_of_epoch = 3
num_of_epoch = 1

nf_set = {
    'app_rdr': '4',
    'app_p2p': '3',
    'app_p2p-controlled': '3',
    'app_tlsv': '6',
    'app_xcdr': '4',
    # zcsi
    'zcsi-nat': '6',
    "zcsi-lpm": '6',
    "zcsi-maglev": '6',
    "zcsi-aclfw": '6',
}

# expr_wait_time = 220  # 180
expr_wait_time = 250  # for rdr 4
xcdr_port_base = 7418
batch = 1

# app
xcdr = ['app_xcdr']
rdr = ['app_rdr']
tlsv = ['app_tlsv', 'app_rdr']
tlsv_rdr = ['app_tlsv']
rdr_xcdr = ['app_rdr', 'app_xcdr']
rdr_xcdr_tlsv = ['app_rdr', 'app_xcdr', 'app_tlsv']
complete_nuclear_list = ['app_p2p', 'app_p2p-ext']
p2p_controlled = ['app_p2p-controlled']
p2p_ext = ['app_p2p-ext']

# nf_list = ['app_p2p-controlled', 'app_rdr', 'app_tlsv', 'app_xcdr']
# nf_list = ['app_xcdr']
# nf_list = ['app_p2p-controlled', 'app_rdr']
# nf_list = ['app_rdr']
# nf_list = ['app_p2p-controlled']

nf_list = [
    "zcsi-maglev",
    "zcsi-lpm",
    'zcsi-nat',
    "zcsi-aclfw"
    'app_tlsv',
]
