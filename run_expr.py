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
        netbricks_sess.enable_logs("netbricks--" + trace + "_" +  nf + "_" + str(epoch) + ".log")
        netbricks_sess.send_commands('ssh jethros@tuco')
        netbricks_sess.send_commands('cd /home/jethros/dev/netbricks/experiments')

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
        pktgen_sess.send_commands('cd /home/jethros/dev/pktgen-dpdk/experiments')

        time.sleep(20)
        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        pktgen_sess.kill()
        sys.exit(1)


def run_pktgen(sess, trace):
    if trace in ['64B', '128B', '256B']:
        size = trace[:-1]
        cmd_str = "sudo ./run_pktgen.sh " + trace
        set_rate_str= "set 0 rate 100"
        set_size_str= "set 0 size " + size
        start_str = "start 0"

        time.sleep(30)
        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_rate_str, set_size_str, start_str)

        time.sleep(10)
        print("Pktgen\nRUN pktgen")
    else:
        cmd_str = "sudo ./run_pktgen.sh " + trace
        set_port_str= "set 0 rate 100"
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


def main(nf_list, trace_list):
    """"""

    pvn_nf_list = ['pvn-tlsv-filter', 'pvn-tlsv-groupby',
            'pvn-rdr-nat-filter', 'pvn-rdr-nat-groupby',
            'pvn-p2p-nat-filter', 'pvn-p2p-nat-groupby',
            'pvn-transcoder-nat-filter', 'pvn-transcoder-nat-groupby'
            ]

    for trace in trace_list:
        print("Running experiments that replay the {} trace".format(trace))
        for nf in nf_list:
            pktgen_sess = pktgen_sess_setup(trace, nf)
            run_pktgen(pktgen_sess, trace)
            for epoch in range(3):
                netbricks_sess = netbricks_sess_setup(trace, nf, epoch)

                if nf in pvn_nf_list:
                    p2p_cleanup(netbricks_sess)
                    time.sleep(60)

                run_netbricks(netbricks_sess, trace, nf, epoch)

                if nf in pvn_nf_list:
                    time.sleep(300)
                    p2p_cleanup(netbricks_sess)
                    time.sleep(60)
                else:
                    time.sleep(300)
                sess_destroy(netbricks_sess)
                # sess_destroy(netbricks_sess)

                if nf in pvn_nf_list:
                    time.sleep(60)
                else:
                    time.sleep(10)

            sess_destroy(pktgen_sess)
            time.sleep(30)
        # try:
        # except Exception as err:
        #     print("exiting nf failed with {}".format(err))


if __name__=='__main__':
    # for simple test
    simple_nf_list = ['pvn-tlsv', 'pvn-rdr-wd-nat', 'pvn-p2p-nat']
    simple_trace_list = ['tls_handshake_trace.pcap', 'ictf2010.pcap14', 'net-2009-11-18-10:32.pcap']

    # Fix again
    now_nf_list = ['pvn-tlsv-re', 'pvn-tlsv',
            'zcsi-maglev', 'zcsi-nat', 'zcsi-lpm', 'zcsi-aclfw',
            'pvn-rdr-wd-nat', 'pvn-p2p-nat', 'pvn-p2p-nat-2',
            ]
    now_trace_list = [
            'ictf2010-0.pcap', 'ictf2010-11.pcap', 'ictf2010-1.pcap',
            'ictf2010-12.pcap', 'ictf2010-10.pcap', 'ictf2010-13.pcap',
            'net-2009-11-23-16:54-re.pcap', 'net-2009-12-07-11:59-re.pcap',
            'net-2009-12-08-11:59-re.pcap',
            ]

    # To fix transcoder
    fix_trans_nf_list = [
            'pvn-transcoder-nat-filter', 'pvn-transcoder-nat-groupby'
            ]
    fix_trans_trace_list = ['tls_handshake_trace.pcap', 'p2p-small-re.pcap',
            'rdr-browsing-re.pcap',
            'net-2009-11-23-16:54-re.pcap', 'net-2009-12-07-11:59-re.pcap',
            'net-2009-12-08-11:59-re.pcap',
            'ictf2010-0.pcap', 'ictf2010-11.pcap', 'ictf2010-1.pcap',
            'ictf2010-12.pcap', 'ictf2010-10.pcap', 'ictf2010-13.pcap',
            '64B', '128B', '256B',
            ]

    test_nf_list = [
            'pvn-tlsv-filter', 'pvn-tlsv-groupby',
            'pvn-rdr-nat-filter', 'pvn-rdr-nat-groupby',
            'pvn-p2p-nat-filter', 'pvn-p2p-nat-groupby',
            'pvn-transcoder-nat-filter', 'pvn-transcoder-nat-groupby'
            ]
    test_trace_list = [
            'ictf2010-0-re.pcap', 'ictf2010-11-re.pcap', 'ictf2010-1-re.pcap',
            'ictf2010-12-re.pcap', 'ictf2010-10-re.pcap', 'ictf2010-13-re.pcap',
            ]

    # Total NF and traces
    nf_list = [
            'pvn-p2p-nat-filter', 'pvn-p2p-nat-groupby',
            'zcsi-maglev', 'zcsi-nat', 'zcsi-lpm', 'zcsi-aclfw',
            'pvn-tlsv-filter', 'pvn-tlsv-groupby',
            'pvn-rdr-nat-filter', 'pvn-rdr-nat-groupby',
            'pvn-transcoder-nat-filter', 'pvn-transcoder-nat-groupby'
            ]
    trace_list = ['tls_handshake_trace.pcap', 'p2p-small-re.pcap',
            'rdr-browsing-re.pcap',
            'net-2009-11-23-16:54-re.pcap', 'net-2009-12-07-11:59-re.pcap',
            'net-2009-12-08-11:59-re.pcap',
            'ictf2010-0-re.pcap', 'ictf2010-11-re.pcap', 'ictf2010-1-re.pcap',
            'ictf2010-12-re.pcap', 'ictf2010-10-re.pcap', 'ictf2010-13-re.pcap',
            '64B', '128B', '256B',
            ]


    # main(simple_nf_list, simple_trace_list)
    # main(test_nf_list, test_trace_list)
    main(nf_list, trace_list)
