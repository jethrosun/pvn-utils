mix_match_nfs = [
    'zcsi-nat',
    'zcsi-lpm',
    'zcsi-maglev',
    'zcsi-aclfw',
    # pvn nf app
    'pvn-rdr-transform-app',
    'pvn-transcoder-transform-app',
    'pvn-tlsv-transform-app',
    # 'pvn-p2p-transform-app',
]

traces = [
    # pktgen
    '64B',
    '128B',
    '512B',
    '1500B',
    'net-2009-11-23-16:54-re.pcap',
    'net-2009-12-07-11:59-re.pcap',
    # 'net-2009-12-08-11:59-re.pcap',
    'ictf2010-0-re.pcap',
    'ictf2010-1-re.pcap',
    # 'ictf2010-10-re.pcap',
    # 'ictf2010-11-re.pcap',
    # 'ictf2010-12-re.pcap',
    # 'ictf2010-13-re.pcap',
    # pvn nf
    'pvn_rdr.pcap',
    'pvn_xcdr.pcap',
    'pvn_tlsv.pcap',
    'pvn_p2p.pcap',
]

rdr_nf_list = [
    'pvn-rdr-transform-app',
    'pvn-rdr-groupby-app',
]

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

xcdr_nf_list = ['pvn-transcoder-transform-app', 'pvn-transcoder-groupby-app']

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

p2p_controlled = ['app_p2p-controlled']
p2p_ext = ['app_p2p-ext']


def fetch_tlsv_trace(setup):
    return 'pvn_tlsv_' + setup + '.pcap'


fixed_sending_rate = 100

# expr is 10 min/600 sec
expr_wait_time = 400

xcdr_port_base = 7418

num_of_epoch = 10
batch = 1
