pvn_nf = {
    # nf app
    'app_rdr': [
        'pvn-rdr-transform-app',
        'pvn-rdr-groupby-app',
    ],
    'app_xcdr': [
        'pvn-transcoder-transform-app',
        'pvn-transcoder-groupby-app',
    ],
    'app_tlsv': [
        'pvn-tlsv-transform-app',
        'pvn-tlsv-groupby-app',
    ],
    'app_p2p': [
        'pvn-p2p-transform-app',
        'pvn-p2p-groupby-app',
    ],
    'app_p2p-ext': [
        'pvn-p2p-transform-app',
        'pvn-p2p-groupby-app',
    ],
    'app_p2p-controlled': [
        'pvn-p2p-groupby-app',
        'pvn-p2p-transform-app',
    ],
    # chain
    'chain_tlsv_rdr': [
        'pvn-tlsv-rdr-coexist-app',
    ],
    'chain_rdr_p2p': [
        'pvn-rdr-p2p-transform-chain',
        'pvn-rdr-p2p-groupby-chain',
    ],
    'chain_rdr_xcdr': [
        'pvn-rdr-xcdr-transform-chain',
        'pvn-rdr-xcdr-groupby-chain',
    ],
    'chain_tlsv_p2p': [
        'pvn-tlsv-p2p-transform-chain',
        'pvn-tlsv-p2p-groupby-chain',
    ],
    'chain_tlsv_xcdr': [
        'pvn-tlsv-xcdr-transform-chain',
        'pvn-tlsv-xcdr-groupby-chain',
    ],
    'chain_xcdr_p2p':[
        'pvn-xcdr-p2p-transform-chain',
        'pvn-xcdr-p2p-groupby-chain',
    ]
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
    'chain_rdr_tlsv': 'pvn_rdr_tlsv.pcap',
    'chain_rdr_p2p': 'pvn_rdr_p2p.pcap',
    'chain_rdr_xcdr': 'pvn_rdr_xcdr.pcap',
    'chain_tlsv_p2p': 'pvn_tlsv_p2p.pcap',
    'chain_tlsv_xcdr': 'pvn_tlsv_xcdr.pcap',
    'chain_xcdr_p2p': 'pvn_xcdr_p2p.pcap',
}

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

pvn_chain_list = [
    'pvn-rdr-tlsv-transform-chain',
    'pvn-rdr-tlsv-groupby-chain',
    'pvn-rdr-xcdr-transform-chain',
    'pvn-rdr-xcdr-groupby-chain',
]


p2p_nf_list = [
    'pvn-p2p-transform-app',
    'pvn-p2p-groupby-app',
]
p2p_chain_list = [
    'pvn-tlsv-p2p-transform-chain',
    'pvn-tlsv-p2p-groupby-chain',
    'pvn-rdr-p2p-transform-chain',
    'pvn-rdr-p2p-groupby-chain',
]

xcdr_nf_list = [
    'pvn-transcoder-transform-app',
    'pvn-transcoder-groupby-app'
]
xcdr_chain_list = [
    'pvn-rdr-xcdr-transform-chain',
    'pvn-rdr-xcdr-groupby-chain',
    'pvn-tlsv-xcdr-transform-chain',
    'pvn-tlsv-xcdr-groupby-chain',
]

xcdr_p2p_chain_list = [
    'pvn-xcdr-p2p-transform-chain',
    'pvn-xcdr-p2p-groupby-chain',
]


set_list = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
]
p2p_ext_list = [
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
]
p2p_controlled_list = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
]


rdr_sending_rate = 10
p2p_sending_rate = 10

fixed_sending_rate = 10
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
        '1': 1,
        '2': 5,
        '3': 10,
        '4': 15,
        '5': 20,
        '6': 50
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
    'chain_rdr_tlsv': {
        '1': fixed_sending_rate,
        '2': fixed_sending_rate,
        '3': fixed_sending_rate,
        '4': fixed_sending_rate,
        '5': fixed_sending_rate,
        '6': fixed_sending_rate
    },
}

# expr is 10 min/600 sec
expr_wait_time = 875

xcdr_port_base = 7418

num_of_epoch = 3
batch = 1


# app

expr_list = ['app_rdr', 'app_xcdr', 'app_tlsv' ]
tmp_list = ['app_rdr', 'app_xcdr', ]
rdr_xcdr_tlsv = ['app_rdr', 'app_xcdr', 'app_tlsv', ]

xcdr = [ 'app_xcdr' ]
rdr = [ 'app_rdr', ]

nuclear_list = [ 'app_p2p' ]
complete_nuclear_list = [ 'app_p2p', 'app_p2p-ext' ]

p2p_controlled = [ 'app_p2p-controlled' ]
p2p_ext = [ 'app_p2p-ext' ]

# chain

chain_tlsv_rdr = [ 'chain_tlsv_rdr', ]

complete_chain = [
    'chain_tlsv_rdr',
    'chain_rdr_p2p',
    'chain_rdr_xcdr',
    'chain_tlsv_p2p',
    'chain_tlsv_xcdr',
    'chain_xcdr_p2p',
]
