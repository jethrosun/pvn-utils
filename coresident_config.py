
pvn_nf = {
        # New coresident cases
        #
        'co_tlsv_rdr_p2p': ['pvn-tlsv-rdr-p2p-coexist-app',],
        'co_tlsv_p2p_xcdr': ['pvn-tlsv-p2p-xcdr-coexist-app',],
        'co_tlsv_rdr_xcdr': ['pvn-tlsv-rdr-xcdr-coexist-app',],
        'co_rdr_xcdr_p2p': ['pvn-rdr-xcdr-p2p-coexist-app',],
        'co_tlsv_rdr_p2p_xcdr': ['pvn-tlsv-rdr-p2p-xcdr-coexist-app',],
        }

trace = {
        'co_tlsv_rdr_p2p': 'pvn-tlsv_rdr_p2p.pcap',
        'co_tlsv_p2p_xcdr': 'pvn-tlsv_p2p_xcdr.pcap',
        'co_tlsv_rdr_xcdr': 'pvn-tlsv_rdr_xcdr.pcap',
        'co_rdr_xcdr_p2p': 'pvn-rdr_xcdr_p2p.pcap',
        'co_tlsv_rdr_p2p_xcdr': 'pvn-tlsv_rdr_p2p_xcdr.pcap',
        }


p2p_co_list = ['pvn-tlsv-rdr-p2p-coexist-app']
xcdr_co_list = ['pvn-tlsv-rdr-xcdr-coexist-app']
xcdr_p2p_co_list = ['pvn-tlsv-p2p-xcdr-coexist-app', 'pvn-rdr-xcdr-p2p-coexist-app', 'pvn-tlsv-rdr-p2p-xcdr-coexist-app']

set_list = ['1', '2', '3', '4', '5', '6']

# 10, 20, 50, 100
fixed_sending_rate = 10
coresident_sending_rate2 = 20
coresident_sending_rate3 = 30
coresident_sending_rate4 = 40
sending_rate = {
        # chain
        #
        #
        'co_tlsv_rdr_p2p':  {
            '1': coresident_sending_rate3,
            '2': coresident_sending_rate3,
            '3': coresident_sending_rate3,
            '4': coresident_sending_rate3,
            '5': coresident_sending_rate3,
            '6': coresident_sending_rate3
            },

        'co_tlsv_p2p_xcdr':  {
            '1': coresident_sending_rate3,
            '2': coresident_sending_rate3,
            '3': coresident_sending_rate3,
            '4': coresident_sending_rate3,
            '5': coresident_sending_rate3,
            '6': coresident_sending_rate3
            },

        'co_tlsv_rdr_xcdr':  {
            '1': coresident_sending_rate3,
            '2': coresident_sending_rate3,
            '3': coresident_sending_rate3,
            '4': coresident_sending_rate3,
            '5': coresident_sending_rate3,
            '6': coresident_sending_rate3
            },

        'co_rdr_xcdr_p2p':  {
            '1': coresident_sending_rate3,
            '2': coresident_sending_rate3,
            '3': coresident_sending_rate3,
            '4': coresident_sending_rate3,
            '5': coresident_sending_rate3,
            '6': coresident_sending_rate3
            },

        'co_tlsv_rdr_p2p_xcdr':  {
            '1': coresident_sending_rate4,
            '2': coresident_sending_rate4,
            '3': coresident_sending_rate4,
            '4': coresident_sending_rate4,
            '5': coresident_sending_rate4,
            '6': coresident_sending_rate4
            },

        }

# expr is 10 min/600 sec
expr_wait_time = 925
batch = 1
xcdr_port_base = 7418

num_of_epoch = 10

p2p_co = [
        'co_tlsv_rdr_p2p',
        'co_tlsv_p2p_xcdr',
        'co_rdr_xcdr_p2p',
        'co_tlsv_rdr_p2p_xcdr'
        ]
non_p2p_co = [
        'co_tlsv_rdr_xcdr'
        ]
