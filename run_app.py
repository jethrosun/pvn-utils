#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time


def netbricks_sess_setup(trace, nf, epoch):
    print("Entering netbricks_sess setup")
    try:
        netbricks_sess = Screen("netbricks", True)
        print("netbricks session is spawned")

        netbricks_sess.send_commands('bash')
        netbricks_sess.enable_logs(
            "netbricks--" + trace + "_" + nf + "_" + str(epoch) + ".log")
        netbricks_sess.send_commands('ssh jethros@tuco')
        netbricks_sess.send_commands(
            'cd /home/jethros/dev/netbricks/experiments')

        time.sleep(15)
        return netbricks_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        netbricks_sess.kill()
        sys.exit(1)


def pktgen_sess_setup(trace, nf):
    print("Entering pktgen_sess setup")
    try:
        pktgen_sess = Screen("pktgen", True)
        print("pktgen session is spawned")

        pktgen_sess.send_commands('bash')
        pktgen_sess.enable_logs("pktgen--" + trace + "_" + nf + ".log")
        pktgen_sess.send_commands(
            'cd /home/jethros/dev/pktgen-dpdk/experiments')

        time.sleep(20)
        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        pktgen_sess.kill()
        sys.exit(1)


def run_pktgen(sess, trace):
    if trace in ['64B', '128B', '256B', '1500B']:
        size = trace[:-1]
        cmd_str = "sudo ./run_pktgen.sh " + trace
        set_rate_str = "set 0 rate 100"
        set_size_str = "set 0 size " + size
        start_str = "start 0"

        time.sleep(30)
        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_rate_str, set_size_str, start_str)

        time.sleep(10)
        print("Pktgen\nRUN pktgen")
    else:
        cmd_str = "sudo ./run_pktgen.sh " + trace
        set_port_str = "set 0 rate 100"
        start_str = "start 0"

        time.sleep(30)
        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_port_str, start_str)

        time.sleep(10)
        print("Pktgen\nRUN pktgen")


def run_netbricks(sess, trace, nf, epoch):
    cmd_str = "sudo ./run_netbricks.sh " + trace + " " + nf + " " + str(epoch)
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def sess_destroy(sess):
    if sess.exists:
        sess.kill()


def p2p_cleanup(sess):
    cmd_str = "sudo ./p2p_cleanup.sh "
    print("Extra clean up for P2P with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def xcdr_cleanup(sess):
    cmd_str = "sudo ./xcdr_cleanup.sh "
    print("Extra clean up for XCDR with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def main(expr_list):
    """"""

    pvn_nf = {
        'app_rdr': [
            'app-rdr_g',
            'app-rdr_t',
        ],
        'app_xcdr': ['app-xcdr_g', 'app-xcdr_t'],
        'app_tlsv': [
            'app-tlsv_g',
            'app-tlsv_t',
        ],
        'app_p2p': [
            'app-p2p_g',
            'app-p2p_t',
        ]
    }
    trace = {
        'app_rdr': 'rdr-browsing-re.pcap',
        'app_xcdr': 'video_trace_2_re.pcap',
        'app_tlsv': 'tls_handshake_trace.pcap',
        'app_p2p': 'p2p-small-re.pcap'
    }
    pvn_nf_list = [
        'app-rdr_g', 'app-rdr_t', 'app-tlsv_g', 'app-tlsv_t', 'app-p2p_g',
        'app-p2p_t', 'app-xcdr_g', 'app-xcdr_t'
    ]
    p2p_nf_list = ['app-p2p_g', 'app-p2p_t']
    xcdr_nf_list = ['app-xcdr_g', 'app-xcdr_t']

    # expr is 10 min/600 sec
    expr_wait_time = 800

    for expr in expr_list:
        print("Running experiments that for {} application NF".format(expr))
        for nf in pvn_nf[expr]:
            pktgen_sess = pktgen_sess_setup(trace[expr], nf)
            run_pktgen(pktgen_sess, trace)
            for epoch in range(5):
                netbricks_sess = netbricks_sess_setup(trace, nf, epoch)

                if nf in p2p_nf_list:
                    p2p_cleanup(netbricks_sess)
                    time.sleep(200)
                elif nf in xcdr_nf_list:
                    xcdr_cleanup(netbricks_sess)
                    time.sleep(200)

                run_netbricks(netbricks_sess, trace, nf, epoch)

                if nf in p2p_nf_list:
                    time.sleep(expr_wait_time)
                    p2p_cleanup(netbricks_sess)
                    time.sleep(150)
                elif nf in pvn_nf_list:
                    time.sleep(expr_wait_time)
                else:
                    time.sleep(expr_wait_time)
                sess_destroy(netbricks_sess)
                # sess_destroy(netbricks_sess)

                if nf in p2p_nf_list:
                    time.sleep(200)
                elif nf in pvn_nf_list:
                    time.sleep(30)
                else:
                    time.sleep(10)

            sess_destroy(pktgen_sess)
            time.sleep(30)
        # try:
        # except Exception as err:
        #     print("exiting nf failed with {}".format(err))


if __name__ == '__main__':
    # for simple test

    # Total NF and traces
    nf_list = [
        'app-rdr_g', 'app-rdr_t', 'app-tlsv_g', 'app-tlsv_t', 'app-p2p_g',
        'app-p2p_t', 'app-xcdr_g', 'app-xcdr_t'
    ]
    trace_list = [
        'tls_handshake_trace.pcap', 'p2p-small-re.pcap',
        'rdr-browsing-re.pcap', 'video_trace_2_re.pcap',
        'net-2009-11-23-16:54-re.pcap', 'net-2009-12-07-11:59-re.pcap',
        'net-2009-12-08-11:59-re.pcap', 'ictf2010-0-re.pcap',
        'ictf2010-11-re.pcap', 'ictf2010-1-re.pcap', 'ictf2010-12-re.pcap',
        'ictf2010-10-re.pcap', 'ictf2010-13-re.pcap', '64B', '128B', '256B',
        '1500B'
    ]
    additional_nf = [
        'pvn-tlsv-transform',
        'pvn-tlsv-groupby',
        'pvn-p2p-transform',
        'pvn-p2p-groupby',
        'pvn-rdr-transform',
        'pvn-rdr-groupby',
        'pvn-transcoder-transform',
        'pvn-transcoder-groupby',
    ]
    additional_trace = ['1500B']
    expr_list = [
        'app_rdr',
        'app_xcdr',
        'app_tlsv',
        'app_p2p',
    ]

    main(expr_list)

    # main(simple_nf_list, simple_trace_list)
    # main(test_nf_list, test_trace_list)
    # main(nf_list, trace_list)
    # main(nf_list, additional_trace)
