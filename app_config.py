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
            ]
        }
trace = {
        'app_rdr': 'rdr-trace-re.pcap',
        'app_xcdr': 'video_trace_2_re.pcap',
        'app_tlsv': 'tls_handshake_trace.pcap',
        'app_p2p': 'p2p-small-re.pcap',
        'app_p2p-ext': 'p2p-small-re.pcap'
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
p2p_set_list = [
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

rdr_sending_rate = 1
p2p_sending_rate = 1
old_sending_rate = {
        'app_xcdr': {
            '1': 1,
            '2': 2,
            '3': 10,
            '4': 20,
            '5': 50,
            '6': 100
            },
        'app_p2p': {
            '1': 3,
            '2': 13,
            '3': 25,
            '4': 50,
            '5': 75,
            '6': 100
            },
        'app_rdr': {
            '1': rdr_sending_rate,
            '2': 2,
            '3': 5,
            '4': 10,
            '5': 15,
            '6': 20
            },
        'app_tlsv': {
            '1': 1,
            '2': 5,
            '3': 10,
            '4': 20,
            '5': 50,
            '6': 100
            },
        'app_p2p-ext': {
            '1': 1,
            '2': 1,
            '3': 1,
            '4': 1,
            '5': 1,
            '6': 1
            },
        }

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
        }

# expr is 10 min/600 sec
expr_wait_time = 630

xcdr_port_base = 7418

num_of_epoch = 3

# Total NF and traces
# nf_list = [
#     'pvn-tlsv-transform-app',
#     'pvn-tlsv-groupby-app',
#     'pvn-p2p-transform-app',
#     'pvn-p2p-groupby-app',
#     'pvn-rdr-transform-app',
#     'pvn-rdr-groupby-app',
#     'pvn-transcoder-transform-app',
#     'pvn-transcoder-groupby-app',
# ]
# trace_list = [
#     'tls_handshake_trace.pcap', 'p2p-small-re.pcap',
#     'rdr-trace-re.pcap', 'video_trace_2_re.pcap',
#     'net-2009-11-23-16:54-re.pcap', 'net-2009-12-07-11:59-re.pcap',
#     'net-2009-12-08-11:59-re.pcap', 'ictf2010-0-re.pcap',
#     'ictf2010-11-re.pcap', 'ictf2010-1-re.pcap', 'ictf2010-12-re.pcap',
#     'ictf2010-10-re.pcap', 'ictf2010-13-re.pcap', '64B', '128B', '256B',
#     '1500B'
# ]
# additional_nf = [
#     'pvn-tlsv-transform',
#     'pvn-tlsv-groupby',
#     'pvn-p2p-transform',
#     'pvn-p2p-groupby',
#     'pvn-rdr-transform',
#     'pvn-rdr-groupby',
#     'pvn-transcoder-transform',
#     'pvn-transcoder-groupby',
# ]
# additional_trace = ['1500B']

all_expr_list = ['app_rdr', 'app_xcdr', 'app_tlsv', 'app_p2p', 'app_p2p-ext']
expr_list = ['app_rdr', 'app_xcdr', 'app_tlsv', 'app_p2p']

only_xcdr_list = [
        'app_xcdr',
        ]
only_p2p_list = [
        'app_p2p',
        ]
only_rdr_list = [
        'app_rdr',
        ]

check_list = ['app_rdr', 'app_p2p']
