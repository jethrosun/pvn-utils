#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time
import coresident_config as coresident


def netbricks_sess_setup(trace, nf, epoch):
    print("Entering netbricks_sess setup")
    try:
        netbricks_sess = Screen("netbricks", True)
        print("netbricks session is spawned")

        netbricks_sess.send_commands('bash')
        netbricks_sess.enable_logs("netbricks--" + trace + "_" + nf + "_" + str(epoch) + ".log")
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


def run_netbricks(sess, trace, nf, epoch, setup):
    cmd_str = "sudo ./run_pvnf_coresident.sh " + trace + " " + nf + " " + str(epoch) + " " + setup
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_netbricks_xcdr(sess, trace, nf, epoch, setup, port1, port2, expr_num):
    cmd_str = "sudo ./run_pvnf_coresident.sh " + trace + " " + nf + " " + str(epoch) + " " + setup + " " + str(7419) + " " + str(7420) + " " + expr_num

    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


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


def main(expr_list):
    """"""
    for expr in expr_list:
        print("Running experiments that for {} application NF".format(expr))
        # app_rdr_g, app_rdr_t; app_p2p_g, app_p2p_t
        for nf in coresident.pvn_nf[expr]:
            # we are running the regular NFs
            # config the pktgen sending rate
            for setup in coresident.set_list:
                pktgen_sess = pktgen_sess_setup(coresident.trace[expr], nf, coresident.sending_rate[expr][setup] * coresident.batch)
                run_pktgen(pktgen_sess, coresident.trace[expr], coresident.sending_rate[expr][setup] * coresident.batch)
                # epoch from 0 to 9
                for epoch in range(coresident.num_of_epoch):
                    netbricks_sess = netbricks_sess_setup(coresident.trace[expr], nf, epoch)

                    rdr_cleanup(netbricks_sess)
                    p2p_cleanup(netbricks_sess)
                    xcdr_cleanup(netbricks_sess)
                    time.sleep(30)

                    # Actual RUN
                    if nf in coresident.xcdr_co_list:
                        expr_num = epoch * 6 + int(setup) * 2
                        port2 = coresident.xcdr_port_base + expr_num
                        run_netbricks_xcdr(netbricks_sess, coresident.trace[expr], nf, epoch, setup, str(port2 - 1), str(port2), str(expr_num))
                    else:
                        run_netbricks(netbricks_sess, coresident.trace[expr], nf, epoch, setup)

                    # run clean up for p2p nf before experiment
                    if nf in coresident.p2p_co_list:
                        time.sleep(coresident.expr_wait_time)
                        p2p_cleanup(netbricks_sess)
                        time.sleep(30)
                    elif nf in coresident.xcdr_co_list:
                        time.sleep(coresident.expr_wait_time)
                        xcdr_cleanup(netbricks_sess)
                        time.sleep(30)
                    elif nf in coresident.xcdr_p2p_co_list:
                        time.sleep(coresident.expr_wait_time)
                        xcdr_cleanup(netbricks_sess)
                        p2p_cleanup(netbricks_sess)
                        time.sleep(30)
                    else:
                        print("Unknown nf?")
                        sys.exit(1)

                    sess_destroy(netbricks_sess)
                    # sess_destroy(netbricks_sess)

                    time.sleep(10)

                sess_destroy(pktgen_sess)
                time.sleep(30)


main(coresident.non_p2p_co)  # rdr, xcdr

print("All experiment finished {}".format(coresident.non_p2p_co))
