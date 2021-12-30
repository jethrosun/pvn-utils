#!/usr/bin/env python

import sys
import time

import nf_config as conf
from screenutils import Screen, list_screens


def netbricks_sess_setup(trace, nf, nf_load):
    # netbricks_sess = netbricks_sess_setup(conf.trace[nf_type], nf, nf_load)
    print("Entering netbricks_sess setup")
    load = ""
    for l in nf_load:
        load += str(l)
    try:
        netbricks_sess = Screen("netbricks", True)
        print("netbricks session is spawned")

        netbricks_sess.send_commands('bash')
        netbricks_sess.enable_logs("netbricks--" + trace + "_" + nf + "_" + load + ".log")
        netbricks_sess.send_commands('ssh jethros@tuco')
        netbricks_sess.send_commands('cd /home/jethros/dev/pvn/utils/faktory_srv')
        netbricks_sess.send_commands('cargo b --release')
        netbricks_sess.send_commands('cd /home/jethros/dev/netbricks/experiments')

        time.sleep(15)
        return netbricks_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        netbricks_sess.kill()
        sys.exit(1)


def pktgen_sess_setup(trace, nf, setup):
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


def run_pktgen(sess, trace, setup):
    cmd_str = "sudo ./run_pktgen.sh " + trace
    print(cmd_str)
    set_port_str = "set 0 rate " + str(setup)
    start_str = "start 0"

    time.sleep(30)
    # print("Pktgen\nStart with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str, set_port_str, start_str)

    time.sleep(10)
    print("Pktgen\nRUN pktgen")


def run_netbricks(sess, trace, nf, nf_load):
    load_str = ""
    for l in nf_load:
        load_str += " "
        load_str += str(l)
    cmd_str = "sudo ./run_pvnf_task.sh " + trace + " " + nf + load_str
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


# def run_netbricks_xcdr(sess, trace, nf, nf_load):
#     load = ""
#     for l in nf_load:
#         load += l
#         load += ":"
#     cmd_str = "sudo ./run_pvnf_coresident.sh " + trace + " " + nf + " " + load
#     print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
#     sess.send_commands(cmd_str)


def sess_destroy(sess):
    if sess.exists:
        sess.kill()


def sess_reboot(sess):
    cmd_str = "sudo reboot"
    sess.send_commands(cmd_str)


def p2p_cleanup(sess):
    cmd_str = "sudo ./misc/p2p_cleanup_nb.sh "
    print("Extra clean up for P2P with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def xcdr_cleanup(sess):
    cmd_str = "sudo ./misc/xcdr_cleanup.sh "
    print("Extra clean up for XCDR with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def rdr_cleanup(sess):
    cmd_str = "sudo ./misc/rdr_cleanup.sh "
    print("Extra clean up for RDR with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def main(raw_tasks):
    for raw_task in raw_tasks:
        print("Running experiments that for {} application NF".format(raw_task))
        nf_type, nf_load = conf.translate(raw_task)
        nf = conf.pvn_nf[nf_type][0]

        sending_rate = sum(nf_load)
        pktgen_sess = pktgen_sess_setup(conf.trace[raw_task], nf, sending_rate)
        run_pktgen(pktgen_sess, conf.trace[raw_task], sending_rate)

        # epoch from 0 to 9
        # for epoch in range(conf.num_of_epoch):
        netbricks_sess = netbricks_sess_setup(conf.trace[raw_task], nf, nf_load)

        p2p_cleanup(netbricks_sess)
        rdr_cleanup(netbricks_sess)
        xcdr_cleanup(netbricks_sess)
        time.sleep(5)

        # Actual RUN
        # if nf in conf.xcdr_clean_list:
        #     run_netbricks_xcdr(netbricks_sess, conf.trace[raw_task], nf, nf_load)
        # else:
        run_netbricks(netbricks_sess, conf.trace[raw_task], nf, nf_load)

        time.sleep(conf.expr_wait_time)

        # run clean up for p2p nf before experiment
        p2p_cleanup(netbricks_sess)
        rdr_cleanup(netbricks_sess)
        xcdr_cleanup(netbricks_sess)
        time.sleep(5)

        sess_destroy(netbricks_sess)
        time.sleep(5)

        sess_destroy(pktgen_sess)
        time.sleep(30)


main(conf.raw_tasks)
print("All experiment finished {}".format(conf.non_p2p_co))
