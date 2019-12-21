#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time


def netbricks_sess_setup():
    print("Entering netbricks_sess setup")
    try:
        netbricks_sess = Screen("netbricks", True)
        print("netbricks session is spawned")

        netbricks_sess.send_commands('bash')
        netbricks_sess.enable_logs("netbricks.log")
        netbricks_sess.send_commands('ssh jethros@tuco')
        netbricks_sess.send_commands('cd /home/jethros/dev/netbricks/experiments')

        return netbricks_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        netbricks_sess.kill()
        sys.exit(1)


def pktgen_sess_setup(trace):
    print("Entering pktgen_sess setup")
    try:
        pktgen_sess = Screen("pktgen", True)
        print("pktgen session is spawned")

        pktgen_sess.send_commands('bash')
        pktgen_sess.enable_logs("pktgen_" +trace+ ".log")
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
    netbricks_sess = netbricks_sess_setup()

    for trace in trace_list:
        pktgen_sess = pktgen_sess_setup(trace)
        print("Running experiments that replay the {} trace".format(trace))
        run_pktgen(pktgen_sess, trace)
        for nf in nf_list:
            for epoch in range(2):
                run_netbricks(netbricks_sess, trace, nf, epoch)
                time.sleep(320)
                # sess_destroy(netbricks_sess)
        sess_destroy(pktgen_sess)
        # try:
        # except Exception as err:
        #     print("exiting nf failed with {}".format(err))
    sess_destroy(netbricks_sess)


if __name__=='__main__':
    nf_list = ['pvn-tlsv-re', 'pvn-tlsv', 'pvn-rdr-wd', 'pvn-p2p',
               'zcsi-maglev', 'zcsi-nat', 'zcsi-lpm', 'zcsi-aclfw']
    trace_list = ['tls_handshake_trace', 'ictf2010.pcap', 'net-2009-11-18-10:32.pcap']

    main(nf_list, trace_list)
