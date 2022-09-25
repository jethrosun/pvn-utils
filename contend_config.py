def fetch_tlsv_trace(setup):
    return 'pvn_tlsv' + setup + '.pcap'


pvn_nf = {
    'app_rdr': 'pvn-rdr-transform-app',
    'app_xcdr': 'pvn-transcoder-transform-app',
    'app_tlsv': 'pvn-tlsv-transform-app',
    'app_p2p-controlled': 'pvn-p2p-transform-app',
    # rand
    'rand1': 'rand1',
    'rand2': 'rand2',
    'rand3': 'rand3',
    'rand4': 'rand4',
}

pvn_trace = {
    'app_rdr': 'pvn_rdr.pcap',
    'app_xcdr': 'pvn_xcdr.pcap',
    'app_p2p-controlled': 'pvn_p2p.pcap',
    'app_tlsv': 'pvn_xcdr.pcap',
    # rand
    'rand1': 'pvn_rdr.pcap',
    'rand2': 'pvn_rdr.pcap',
    'rand3': 'pvn_rdr.pcap',
    'rand4': 'pvn_rdr.pcap',
}

nf_set = {
    'app_rdr': '1',
    'app_p2p-controlled': '1',
    'app_tlsv': '1',
    'app_xcdr': '1',
    # rand
    'rand1': '1',
    'rand2': '1',
    'rand3': '1',
    'rand4': '1',
}


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


sending_rate = 10

# tlsv
# -------------------------
expr_wait_time = 190
num_of_epoch = 3
nf_list = [
    'app_tlsv'
]
