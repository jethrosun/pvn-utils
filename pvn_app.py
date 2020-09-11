#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time
import app_config as app

def netbricks_sess_setup(trace, nf, epoch):
    print("Entering netbricks_sess setup")
    try:
        netbricks_sess = Screen("netbricks", True)
        print("netbricks session is spawned")

        netbricks_sess.send_commands('bash')
        netbricks_sess.enable_logs("netbricks--" + trace + "_" + nf + "_" +
                                   str(epoch) + ".log")
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
        pktgen_sess.send_commands(
            'cd /home/jethros/dev/pktgen-dpdk/experiments')

        time.sleep(20)
        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        pktgen_sess.kill()
        sys.exit(1)


def run_pktgen(sess, trace, setup):
    # never here
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
        print(cmd_str)
        set_port_str = "set 0 rate " + str(setup)
        start_str = "start 0"

        time.sleep(30)
        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_port_str, start_str)

        time.sleep(10)
        print("Pktgen\nRUN pktgen")


def run_netbricks(sess, trace, nf, epoch, setup):
    cmd_str = "sudo ./run_netbricks_app.sh " + trace + " " + nf + " " + str(
        epoch) + " " + setup
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_netbricks_xcdr(sess, trace, nf, epoch, setup, port1, port2, expr_num):
    cmd_str = "sudo ./run_netbricks_app.sh " + trace + " " + nf + " " + str(
        epoch) + " " + setup + " " + port1 + " " + port2 + " " + expr_num
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def sess_destroy(sess):
    if sess.exists:
        sess.kill()


def p2p_cleanup(sess):
    cmd_str = "sudo ./misc/p2p_cleanup.sh "
    print("Extra clean up for P2P with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def xcdr_cleanup(sess):
    cmd_str = "sudo ./misc/xcdr_cleanup.sh "
    print("Extra clean up for XCDR with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def main(expr_list, batch):
    """"""
    # app rdr, app p2p ...
    for expr in expr_list:
        print("Running experiments that for {} application NF".format(expr))
        # app_rdr_g, app_rdr_t; app_p2p_g, app_p2p_t
        for nf in app.pvn_nf[expr]:
            # we are running the regular NFs
            if expr != 'app_p2p-ext':
                # config the pktgen sending rate
                for setup in app.set_list:
                    pktgen_sess = pktgen_sess_setup(app.trace[expr], nf,
                                                    app.sending_rate[expr][setup]*batch)
                    run_pktgen(pktgen_sess, app.trace[expr],
                               app.sending_rate[expr][setup]*batch)
                    # epoch from 0 to 9
                    for epoch in range(app.num_of_epoch):
                        netbricks_sess = netbricks_sess_setup(
                            app.trace[expr], nf, epoch)

                        # run clean up for p2p nf before experiment
                        if nf in app.p2p_nf_list:
                            p2p_cleanup(netbricks_sess)
                            time.sleep(60)
                        elif nf in app.xcdr_nf_list:
                            xcdr_cleanup(netbricks_sess)
                            time.sleep(60)

                        # Actual RUN
                        if nf in app.xcdr_nf_list:
                            expr_num = epoch * 6 + int(setup) * 2
                            port2 = app.xcdr_port_base + expr_num
                            run_netbricks_xcdr(netbricks_sess, app.trace[expr], nf,
                                               epoch, setup, str(port2 - 1),
                                               str(port2), str(expr_num))
                        else:
                            run_netbricks(netbricks_sess, app.trace[expr], nf,
                                          epoch, setup)

                        # run clean up for p2p nf before experiment
                        if nf in app.p2p_nf_list:
                            time.sleep(app.expr_wait_time)
                            p2p_cleanup(netbricks_sess)
                            time.sleep(60)
                        elif nf in app.xcdr_nf_list:
                            time.sleep(app.expr_wait_time)
                            xcdr_cleanup(netbricks_sess)
                            time.sleep(60)
                        elif nf in app.pvn_nf_list:
                            time.sleep(app.expr_wait_time)
                        else:
                            print("Unknown nf?")
                            sys.exit(1)

                        sess_destroy(netbricks_sess)
                        # sess_destroy(netbricks_sess)

                        if nf in app.p2p_nf_list:
                            time.sleep(60)
                        elif nf in app.xcdr_nf_list:
                            time.sleep(60)
                        elif nf in app.pvn_nf_list:
                            time.sleep(30)
                        else:
                            time.sleep(10)

                    sess_destroy(pktgen_sess)
                    time.sleep(60)

            elif expr == 'app_p2p-ext':
                # config the pktgen sending rate
                for setup in app.p2p_set_list:
                    pktgen_sess = pktgen_sess_setup(app.trace[expr], nf,
                                                    app.p2p_sending_rate*batch)
                    run_pktgen(pktgen_sess, app.trace[expr], app.p2p_sending_rate*batch)
                    # epoch from 0 to 9
                    for epoch in range(5):
                        netbricks_sess = netbricks_sess_setup(
                            app.trace[expr], nf, epoch)

                        # run clean up for p2p nf before experiment
                        if nf in app.p2p_nf_list:
                            p2p_cleanup(netbricks_sess)
                            time.sleep(60)
                        elif nf in app.xcdr_nf_list:
                            xcdr_cleanup(netbricks_sess)
                            time.sleep(60)

                        # Actual RUN
                        if nf in app.xcdr_nf_list:
                            expr_num = epoch * 6 + int(setup) * 2
                            port2 = app.xcdr_port_base + expr_num
                            run_netbricks_xcdr(netbricks_sess, app.trace[expr], nf,
                                               epoch, setup, str(port2 - 1),
                                               str(port2), str(expr_num))
                        else:
                            run_netbricks(netbricks_sess, app.trace[expr], nf,
                                          epoch, setup)

                        # run clean up for p2p nf before experiment
                        if nf in app.p2p_nf_list:
                            time.sleep(app.expr_wait_time)
                            p2p_cleanup(netbricks_sess)
                            time.sleep(60)
                        elif nf in app.xcdr_nf_list:
                            time.sleep(app.expr_wait_time)
                            xcdr_cleanup(netbricks_sess)
                            time.sleep(60)
                        elif nf in app.pvn_nf_list:
                            time.sleep(app.expr_wait_time)
                        else:
                            print("Unknown nf?")
                            sys.exit(1)

                        sess_destroy(netbricks_sess)
                        # sess_destroy(netbricks_sess)

                        if nf in app.p2p_nf_list:
                            time.sleep(60)
                        elif nf in app.xcdr_nf_list:
                            time.sleep(60)
                        elif nf in app.pvn_nf_list:
                            time.sleep(30)
                        else:
                            time.sleep(10)

                    sess_destroy(pktgen_sess)
                    time.sleep(60)


main(app.metric_list, 1)
