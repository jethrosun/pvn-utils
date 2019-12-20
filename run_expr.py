#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time


def netbricks_sess_setup():
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


def pktgen_sess_setup():
    try:
        pktgen_sess = Screen("pktgen", True)
        print("pktgen session is spawned")

        pktgen_sess.send_commands('bash')
        pktgen_sess.enable_logs("pktgen.log")
        pktgen_sess.send_commands('cd /home/jethros/dev/pktgen-dpdk/experiments')

        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))

        pktgen_sess.kill()

        sys.exit(1)


def sess_destroy(sess):
    # sess.send_commands("quit")

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
    cmd_str = "sudo ./run_netbricks.sh " + nf
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def main(nf_list, trace_list):
    """"""
    netbricks_sess = netbricks_sess_setup()
    pktgen_sess = pktgen_sess_setup()

    for trace in trace_list:
        print("Running experiments that replay the {} trace".format(trace))
        run_pktgen(pktgen_sess, trace)
        for nf in nf_list:
            for epoch in range(2):
                run_netbricks(netbricks_sess, trace, nf, epoch)
                time.sleep(90)
                # sess_destroy(netbricks_sess)
        sess_destroy(pktgen_sess)


if __name__=='__main__':
    nf_list = ['pvn-tlsv-re', 'pvn-tlsv']
    trace_list = ['tls_handshake']

    main(nf_list, trace_list)
