pvn_nf = {
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
            'pvn-p2p-transform-app',
            'pvn-p2p-groupby-app',
            ],
        }
trace = {
        'app_rdr': 'rdr-trace-re.pcap',
        'app_xcdr': 'video_trace_2_re.pcap',
        'app_tlsv': 'tls_handshake_trace.pcap',
        'app_p2p': 'p2p-small-re.pcap',
        'app_p2p-ext': 'p2p-small-re.pcap',
        'app_p2p-controlled': 'p2p-small-re.pcap'
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

p2p_nf_list = [
        'pvn-p2p-transform-app',
        'pvn-p2p-groupby-app',
        ]
xcdr_nf_list = [
        'pvn-transcoder-transform-app', 'pvn-transcoder-groupby-app'
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


rdr_sending_rate = 1
p2p_sending_rate = 1

batch = 2

fixed_sending_rate = 3
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
            '2': 2,
            '3': 4,
            '4': 6,
            '5': 8,
            '6': 10
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
        }

# expr is 10 min/600 sec
expr_wait_time = 675

xcdr_port_base = 7418

num_of_epoch = 3


# expr list....

all_expr_list = ['app_rdr', 'app_xcdr', 'app_tlsv', ]
expr_list = ['app_rdr', 'app_xcdr', 'app_tlsv' ]
metric_list = ['app_rdr', 'app_xcdr', ]

xcdr = [ 'app_xcdr' ]
rdr = [ 'app_rdr', ]


nuclear_list = [ 'app_p2p' ]
complete_nuclear_list = [ 'app_p2p', 'app_p2p-ext' ]

p2p_controlled = [ 'app_p2p-controlled' ]
p2p_ext = [ 'app_p2p-ext' ]

