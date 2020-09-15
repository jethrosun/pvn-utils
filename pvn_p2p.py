#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time
import app_config as app


def netbricks_sess_setup(trace, nf, epoch, expr):
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


def pktgen_sess_setup(trace, nf, epoch):
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


def p2p_sess_setup(node, trace, nf, epoch):
    p2p_nodes = {'provenza': 'seeder',
                 'flynn': 'leecher',
                 'tao': 'leecher',
                 'sanchez': 'leecher',}
    p2p_ips = {'provenza': '10.200.111.125',
               'flynn': '10.200.111.124',
               'tao': '10.200.111.123',
               'sanchez': '10.200.111.122',}

    print("Entering p2p_sess setup for {} as {}".format(node, p2p_nodes[node]))
    try:
        p2p_sess = Screen(node, True)
        print("p2p session for {} is spawned".format(node))

        p2p_sess.send_commands('bash')
        p2p_sess.enable_logs(node + "--" + trace + "_" + nf + ".log")
        p2p_sess.send_commands('ssh jethros@' + p2p_ips[node])
        p2p_sess.send_commands('cd /home/jethros/dev/pvn/utils/p2p_expr')
        p2p_sess.send_commands('git pull')

        time.sleep(20)
        return p2p_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        p2p_sess.kill()
        sys.exit(1)


def run_pktgen(sess, trace, rate):
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
        set_port_str = "set 0 rate " + str(rate)
        start_str = "start 0"

        time.sleep(30)
        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_port_str, start_str)

        time.sleep(10)
        print("Pktgen\nRUN pktgen")


def run_netbricks(sess, trace, nf, epoch, setup, expr):
    cmd_str = "sudo ./run_netbricks_app.sh " + trace + " " + nf + " " + str(
        epoch) + " " + setup + " " + expr
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_p2p_node(typ, sess, setup):
    if typ == "leecher":
        cmd_str = "sudo ./p2p_run_leecher.sh " + setup + " &"
        print("Run P2P Leecher \n\tCmd: {}".format(cmd_str))
        sess.send_commands(cmd_str)
    else:
        print("Unknown type: {}".format(typ))


def sess_destroy(sess):
    if sess.exists:
        sess.kill()


def p2p_cleanup(typ, sess):
    if typ == "netbricks":
        cmd_str = "sudo ./misc/p2p_cleanup.sh "
        sess.send_commands(cmd_str)
        p2p_cmd_str = "sudo ./../p2p_expr/p2p_cleanup_leecher.sh"
        sess.send_commands(p2p_cmd_str)
        print("NetBricks P2P clean up with cmd: {}".format(cmd_str))
    elif typ == "leecher":
        cmd_str = "sudo ./p2p_cleanup_leecher.sh "
        print("Leecher P2P clean up with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str)
    else:
        print("Unknown p2p node type {}".format(typ))


def run_expr_p2p(expr, batch):
    for nf in app.pvn_nf[expr]:
        # we are running the regular NFs
        # config the pktgen sending rate
        for setup in app.p2p_controlled_list:
            pktgen_sess = pktgen_sess_setup(app.trace[expr], nf,
                                            app.p2p_sending_rate*batch)
            run_pktgen(pktgen_sess, app.trace[expr], app.p2p_sending_rate*batch)
            # epoch from 0 to 9
            for epoch in range(5):
                netbricks_sess = netbricks_sess_setup(app.trace[expr], nf, epoch,
                                                      expr)

                leecher1_sess = p2p_sess_setup('flynn', app.trace[expr], nf, epoch)
                leecher2_sess = p2p_sess_setup('tao', app.trace[expr], nf, epoch)
                leecher3_sess = p2p_sess_setup('sanchez', app.trace[expr], nf, epoch)

                # run clean up for p2p nf before experiment
                p2p_cleanup("netbricks", netbricks_sess)
                p2p_cleanup("leecher", leecher1_sess)
                p2p_cleanup("leecher", leecher2_sess)
                p2p_cleanup("leecher", leecher2_sess)
                time.sleep(60)

                # Actual RUN
                run_p2p_node('leecher', leecher1_sess, setup)
                run_p2p_node('leecher', leecher2_sess, setup)
                run_p2p_node('leecher', leecher3_sess, setup)
                run_netbricks(netbricks_sess, app.trace[expr], nf, epoch, setup,
                              expr)

                time.sleep(app.expr_wait_time)

                # run clean up for p2p nf before experiment
                p2p_cleanup("netbricks", netbricks_sess)
                p2p_cleanup("leecher", leecher1_sess)
                p2p_cleanup("leecher", leecher2_sess)
                p2p_cleanup("leecher", leecher3_sess)
                time.sleep(60)

                sess_destroy(netbricks_sess)
                sess_destroy(leecher1_sess)
                sess_destroy(leecher2_sess)
                sess_destroy(leecher3_sess)

                time.sleep(60)

            sess_destroy(pktgen_sess)
            time.sleep(60)


def run_expr_p2p_controlled(expr, batch):
    print("running controlled")
    for nf in app.pvn_nf[expr]:
        # we are running the regular NFs
        # config the pktgen sending rate
        for setup in app.p2p_controlled_list:
            pktgen_sess = pktgen_sess_setup(app.trace[expr], nf,
                                            app.p2p_sending_rate*batch)
            run_pktgen(pktgen_sess, app.trace[expr], app.p2p_sending_rate*batch)
            # epoch from 0 to 9
            for epoch in range(5):
                netbricks_sess = netbricks_sess_setup(app.trace[expr], nf, epoch,
                                                      expr)

                leecher1_sess = p2p_sess_setup('flynn', app.trace[expr], nf, epoch)
                leecher2_sess = p2p_sess_setup('tao', app.trace[expr], nf, epoch)
                leecher3_sess = p2p_sess_setup('sanchez', app.trace[expr], nf, epoch)

                # run clean up for p2p nf before experiment
                p2p_cleanup("netbricks", netbricks_sess)
                p2p_cleanup("leecher", leecher1_sess)
                p2p_cleanup("leecher", leecher2_sess)
                p2p_cleanup("leecher", leecher2_sess)
                time.sleep(60)

                # Actual RUN
                run_p2p_node('leecher', leecher1_sess, setup)
                run_p2p_node('leecher', leecher2_sess, setup)
                run_p2p_node('leecher', leecher3_sess, setup)
                run_netbricks(netbricks_sess, app.trace[expr], nf, epoch, setup,
                              expr)

                time.sleep(app.expr_wait_time)

                # run clean up for p2p nf before experiment
                p2p_cleanup("netbricks", netbricks_sess)
                p2p_cleanup("leecher", leecher1_sess)
                p2p_cleanup("leecher", leecher2_sess)
                p2p_cleanup("leecher", leecher3_sess)
                time.sleep(60)

                sess_destroy(netbricks_sess)
                sess_destroy(leecher1_sess)
                sess_destroy(leecher2_sess)
                sess_destroy(leecher3_sess)

                time.sleep(60)

            sess_destroy(pktgen_sess)
            time.sleep(60)


def run_expr_p2p_ext(expr, batch):
    for nf in app.pvn_nf[expr]:
        # we are running the regular NFs
        # config the pktgen sending rate
        for setup in app.p2p_ext_list:
            pktgen_sess = pktgen_sess_setup(app.trace[expr], nf,
                                            app.p2p_sending_rate*batch)
            run_pktgen(pktgen_sess, app.trace[expr], app.p2p_sending_rate*batch)
            # epoch from 0 to 9
            for epoch in range(5):
                netbricks_sess = netbricks_sess_setup(app.trace[expr], nf, epoch)

                # run clean up for p2p nf before experiment
                p2p_cleanup(netbricks_sess)
                time.sleep(60)

                # Actual RUN
                run_netbricks(netbricks_sess, app.trace[expr], nf, epoch, setup)

                # run clean up for p2p nf before experiment
                if nf in app.p2p_nf_list:
                    time.sleep(app.expr_wait_time)
                    p2p_cleanup(netbricks_sess)
                    time.sleep(60)
                else:
                    print("Unknown nf?")
                    sys.exit(1)

                sess_destroy(netbricks_sess)
                # sess_destroy(netbricks_sess)

                if nf in app.p2p_nf_list:
                    time.sleep(60)
                else:
                    time.sleep(10)

            sess_destroy(pktgen_sess)
            time.sleep(60)


def main(expr_list, batch):
    """"""
    # app rdr, app p2p ...
    for expr in expr_list:
        print("Running experiments that for {} application NF".format(expr))
        # app_rdr_g, app_rdr_t; app_p2p_g, app_p2p_t
        if expr == "p2p":
            run_expr_p2p(expr, batch)
        elif expr == "app_p2p-controlled":
            run_expr_p2p_controlled(expr, batch)
        elif expr == "app_p2p-ext":
            run_expr_p2p_ext(expr, batch)


if __name__ == '__main__':
    main(app.p2p_controlled, 2)
    # main(p2p_ext, 5)
