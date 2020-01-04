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

        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        pktgen_sess.kill()
        sys.exit(1)


def sess_destroy(sess):
    if sess.exists:
        sess.kill()

def run_pktgen(sess, trace):
    if trace in ['64B', '128B', '256B']:
        size = trace[:-1]
        cmd_str = "sudo ./run_pktgen.sh " + trace
        set_rate_str= "set 0 rate 100"
        set_size_str= "set 0 size " + size
        start_str = "start 0"

        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_rate_str, set_size_str, start_str)
        print("Pktgen\nRUN pktgen")
    else:
        cmd_str = "sudo ./run_pktgen.sh " + trace
        set_port_str= "set 0 rate 100"
        start_str = "start 0"

        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_port_str, start_str)
        print("Pktgen\nRUN pktgen")

        # return pktgen_sess


def run_netbricks(sess, trace, nf, epoch):
    cmd_str = "sudo ./run_netbricks.sh " + trace + " " + nf + " " + str(epoch)
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def main(nf_list, trace_list):
    """"""

    for trace in trace_list:
        print("Running experiments that replay the {} trace".format(trace))
        for nf in nf_list:
            pktgen_sess = pktgen_sess_setup(trace, nf)
            run_pktgen(pktgen_sess, trace)
            for epoch in range(2):
                netbricks_sess = netbricks_sess_setup(trace, nf, epoch)
                run_netbricks(netbricks_sess, trace, nf, epoch)
                # NOTE: we know each measurement in each run takes 60 seconds
                # and the duration is 65 seconds.
                # time.sleep(320)
                time.sleep(120)
                sess_destroy(netbricks_sess)
                # sess_destroy(netbricks_sess)
            sess_destroy(pktgen_sess)
            time.sleep(15)
        # try:
        # except Exception as err:
        #     print("exiting nf failed with {}".format(err))


if __name__=='__main__':
    nf_list = ['pvn-tlsv-re', 'pvn-tlsv',
               'zcsi-maglev', 'zcsi-nat', 'zcsi-lpm', 'zcsi-aclfw',
                'pvn-rdr-wd-nat', 'pvn-p2p-nat', 'pvn-p2p-nat-2',
               ]
    trace_list = ['tls_handshake_trace.pcap', 'p2p-small.pcap',
                  'ictf2010.pcap10', 'ictf2010.pcap14', 'ictf2010.pcap',
                  'net-2009-11-18-10:32.pcap', 'net-2009-11-18-17:35.pcap',
                  'net-2009-11-23-16:54.pcap', 'rdr-browsing.pcap',
                  '64B', '128B', '256B',
                  ]

    simple_nf_list = ['pvn-tlsv', 'pvn-rdr-wd-nat', 'pvn-p2p-nat']
    simple_trace_list = ['tls_handshake_trace', 'ictf2010.pcap14', 'net-2009-11-18-10:32.pcap']

    # main(nf_list, trace_list)
    main(simple_nf_list, simple_trace_list)
