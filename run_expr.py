#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time


def netbricks_sess_setup(trace, nf, epoch):
    try:
        netbricks_sess = Screen("netbricks", True)
        print("netbricks session is spawned")

        netbricks_sess.send_commands('bash')
        netbricks_sess.enable_logs(trace + "_" + nf + "--netbricks_" + epoch
                                   + ".log")
        netbricks_sess.send_commands('ssh jethros@tuco')
        netbricks_sess.send_commands('cd /home/jethros/dev/netbricks/experiments')

        return netbricks_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        sys.exit(1)


def pktgen_sess_setup(trace):
    try:
        pktgen_sess = Screen("pktgen", True)
        print("pktgen session is spawned")

        pktgen_sess.send_commands('bash')
        pktgen_sess.enable_logs(trace + "--pktgen.log")
        pktgen_sess.send_commands('cd /home/jethros/dev/pktgen-dpdk')

        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        sys.exit(1)



def sess_destroy(sess):
    sess.kill()


def run_pktgen(trace):
    cmd_str = "./run_pktgen.sh " + trace
    pktgen_sess = pktgen_sess_setup(trace)
    print("Run Pktgen\nTry to run with cmd: {}".format(cmd_str))
    pktgen_sess.send_commands(cmd_str)
    return pktgen_sess


def run_netbricks(trace, nf, epoch):
    cmd_str = "./run_netbricks.sh" + nf
    netbricks_sess = netbricks_sess_setup(trace, nf, epoch)
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    netbricks_sess.send_commands(cmd_str)
    pass


def main(nf_list, trace_list):
    """"""
    for trace in trace_list:
        print("Running experiments that replay the {} trace".format(trace))
        pktgen_sess = run_pktgen(trace)
        for nf in nf_list:
            for epoch in range(10):
                netbricks_sess = run_netbricks(trace, nf, epoch)
                time.sleep(90)
                sess_destroy(netbricks_sess)
        sess_destroy(pktgen_sess)


if __name__=='__main__':
    nf_list = ['pvn-tlsv-re', 'pvn-tlsv']
    trace_list = ['tls_handshake']

    main(nf_list, trace_list)
