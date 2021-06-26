def fetch_tlsv_trace(setup):
    return 'pvn_tlsv' + setup + '.pcap'


pvn_nf = {
    # nf app
    'app_rdr': [
        'pvn-rdr-transform-app',
        # 'pvn-rdr-groupby-app',
    ],
    'app_xcdr': [
        'pvn-transcoder-transform-app',
        # 'pvn-transcoder-groupby-app',
    ],
    'app_tlsv': [
        'pvn-tlsv-transform-app',
        # 'pvn-tlsv-groupby-app',
    ],
    'app_p2p': [
        'pvn-p2p-transform-app',
        # 'pvn-p2p-groupby-app',
    ],
    'app_p2p-ext': [
        'pvn-p2p-transform-app',
        # 'pvn-p2p-groupby-app',
    ],
    'app_p2p-controlled': [
        'pvn-p2p-transform-app',
        # 'pvn-p2p-groupby-app',
    ],
    # chain
    'chain_tlsv_rdr': ['pvn-tlsv-rdr-coexist-app',],
    'chain_rdr_p2p': ['pvn-rdr-p2p-coexist-app',],
    'chain_rdr_xcdr': ['pvn-rdr-xcdr-coexist-app',],
    'chain_tlsv_p2p': ['pvn-tlsv-p2p-coexist-app',],
    'chain_tlsv_xcdr': ['pvn-tlsv-xcdr-coexist-app',],
    'chain_xcdr_p2p': ['pvn-xcdr-p2p-coexist-app',]
}

trace = {
    # nf
    'app_rdr': 'pvn_rdr.pcap',
    'app_xcdr': 'pvn_xcdr.pcap',
    'app_tlsv': 'pvn_tlsv.pcap',
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
}

rdr_nf_list = ['pvn-rdr-transform-app', 'pvn-rdr-groupby-app']

pvn_nf_list = [
    'pvn-tlsv-transform-app',
    'pvn-tlsv-groupby-app',
    'pvn-p2p-transform-app',
    'pvn-p2p-groupby-app',
    'pvn-rdr-transform-app',
    'pvn-rdr-groupby-app',
    'pvn-transcoder-transform-app',
    'pvn-transcoder-groupby-app',
]

pvn_chain_list = ['pvn-tlsv-rdr-coexist-app']

p2p_nf_list = ['pvn-p2p-transform-app', 'pvn-p2p-groupby-app']
p2p_chain_list = ['pvn-tlsv-p2p-coexist-app', 'pvn-rdr-p2p-coexist-app', 'pvn-xcdr-p2p-coexist-app']

xcdr_nf_list = ['pvn-transcoder-transform-app', 'pvn-transcoder-groupby-app']
xcdr_chain_list = ['pvn-rdr-xcdr-coexist-app', 'pvn-tlsv-xcdr-coexist-app']
xcdr_p2p_chain_list = ['pvn-xcdr-p2p-coexist-app']

set_list = ['1', '2', '3', '4', '5', '6']
p2p_ext_list = ['11', '12', '13', '14', '15', '16', '17', '18', '19', '20']

# 10, 20, 50, 100
fixed_sending_rate = 100
coresident_sending_rate = 20
sending_rate = {
    'app_xcdr': {
        '1': fixed_sending_rate,
        '2': fixed_sending_rate,
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
        '5': fixed_sending_rate,
        '6': fixed_sending_rate
    },
    'app_p2p': {
        '1': fixed_sending_rate,
        '2': fixed_sending_rate,
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
        '5': fixed_sending_rate,
        '6': fixed_sending_rate
    },
    'app_rdr': {
        '1': fixed_sending_rate,
        '2': fixed_sending_rate,
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
        '5': fixed_sending_rate,
        '6': fixed_sending_rate
    },
    'app_tlsv': {
        '1': fixed_sending_rate,
        '2': fixed_sending_rate,
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
        '5': fixed_sending_rate,
        '6': fixed_sending_rate
    },
    'app_p2p-ext': {
        '1': fixed_sending_rate,
        '2': fixed_sending_rate,
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
        '5': fixed_sending_rate,
        '6': fixed_sending_rate
    },
    'app_p2p-controlled': {
        '1': fixed_sending_rate,
        '2': fixed_sending_rate,
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
        '5': fixed_sending_rate,
        '6': fixed_sending_rate
    },
    # chain
    'chain_tlsv_rdr': {
        '1': coresident_sending_rate,
        '2': coresident_sending_rate,
        '3': coresident_sending_rate,
        '4': coresident_sending_rate,
        '5': coresident_sending_rate,
        '6': coresident_sending_rate
    },
    'chain_rdr_p2p': {
        '1': coresident_sending_rate,
        '2': coresident_sending_rate,
        '3': coresident_sending_rate,
        '4': coresident_sending_rate,
        '5': coresident_sending_rate,
        '6': coresident_sending_rate
    },
    'chain_rdr_xcdr': {
        '1': coresident_sending_rate,
        '2': coresident_sending_rate,
        '3': coresident_sending_rate,
        '4': coresident_sending_rate,
        '5': coresident_sending_rate,
        '6': coresident_sending_rate
    },
    'chain_tlsv_p2p': {
        '1': coresident_sending_rate,
        '2': coresident_sending_rate,
        '3': coresident_sending_rate,
        '4': coresident_sending_rate,
        '5': coresident_sending_rate,
        '6': coresident_sending_rate
    },
    'chain_tlsv_xcdr': {
        '1': coresident_sending_rate,
        '2': coresident_sending_rate,
        '3': coresident_sending_rate,
        '4': coresident_sending_rate,
        '5': coresident_sending_rate,
        '6': coresident_sending_rate
    },
    'chain_xcdr_p2p': {
        '1': coresident_sending_rate,
        '2': coresident_sending_rate,
        '3': coresident_sending_rate,
        '4': coresident_sending_rate,
        '5': coresident_sending_rate,
        '6': coresident_sending_rate
    },
}

# expr is 10 min/600 sec
expr_wait_time = 925

xcdr_port_base = 7418

num_of_epoch = 10
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

# chain

chain_tlsv_rdr = [
    'chain_tlsv_rdr',
]

p2p_chain = [
    'chain_rdr_p2p',
    'chain_tlsv_p2p',
    'chain_xcdr_p2p',
]
non_p2p_chain = [
    'chain_tlsv_rdr',
    'chain_rdr_xcdr',
    'chain_tlsv_xcdr',
]
