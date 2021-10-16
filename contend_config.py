def fetch_tlsv_trace(setup):
    return 'pvn_tlsv' + setup + '.pcap'


pvn_nf = {
    'app_rdr': ['pvn-rdr-transform-app'],
    'app_xcdr': ['pvn-transcoder-transform-app'],
    'app_tlsv': ['pvn-tlsv-transform-app'],
    'app_p2p': ['pvn-p2p-transform-app'],
    'app_p2p-ext': ['pvn-p2p-transform-app'],
    'app_p2p-controlled': ['pvn-p2p-transform-app'],
}

trace = {
    'app_rdr': 'pvn_rdr.pcap',
    'app_xcdr': 'pvn_xcdr.pcap',
    'app_tlsv': 'pvn_tlsv6.pcap',
    'app_p2p': 'pvn_p2p.pcap',
    'app_p2p-ext': 'pvn_p2p.pcap',
    'app_p2p-controlled': 'pvn_p2p.pcap',
}

rdr_nf_list = ['pvn-rdr-transform-app', 'pvn-rdr-groupby-app']

pvn_nf_list = [
    'pvn-tlsv-transform-app',
    'pvn-p2p-transform-app',
    'pvn-rdr-transform-app',
    'pvn-transcoder-transform-app',
]

p2p_nf_list = ['pvn-p2p-transform-app', 'pvn-p2p-groupby-app']
rdr_nf_list = ['pvn-rdr-transform-app', 'pvn-p2p-groupby-app']
xcdr_nf_list = ['pvn-transcoder-transform-app', 'pvn-transcoder-groupby-app']

nf_set = {
    'app_xcdr': '4',
    'app_p2p': '4',
    'app_rdr': '3',
    'app_tlsv': '6',
    'app_p2p-ext': '4',
    'app_p2p-controlled': '4',
}

# 10, 20, 50, 100
fixed_sending_rate = 10
coresident_sending_rate = 20
sending_rate = {
    'app_xcdr': {
        '4': fixed_sending_rate,
    },
    'app_p2p': {
        '4': fixed_sending_rate,
    },
    'app_rdr': {
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
    },
    'app_tlsv': {
        '6': fixed_sending_rate
    },
    'app_p2p-ext': {
        '4': fixed_sending_rate,
    },
    'app_p2p-controlled': {
        '4': fixed_sending_rate,
    },
}

setup = []

# NOTE: zero is only for testing purposes and should not be used in real
# experiments
zero = '0'
#for i in ['3']:
for i in ['1', '3']:
    setup.append([i, zero, zero])
    setup.append([zero, i, zero])
    setup.append([zero, zero, i])
    # setup.append([i, i, zero])
    # setup.append([i, zero, i])
    # setup.append([zero, i, i])
    # setup.append([i, i, i])
num_of_epoch = 1
# num_of_epoch = 10

# expr is 10 min/600 sec
expr_wait_time = 925
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

# nf_list = [ 'app_rdr', 'app_xcdr', 'app_p2p-controlled']
nf_list = ['app_tlsv', 'app_xcdr', 'app_p2p-controlled', 'app_rdr']
# nf_list = ['app_p2p-controlled']
