#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time
import contend_config as contend


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
        netbricks_sess.send_commands('cd /home/jethros/dev/pvn/utils/contention_cpu')
        netbricks_sess.send_commands('cargo b --release')
        netbricks_sess.send_commands('cd /home/jethros/dev/pvn/utils/contention_mem')
        netbricks_sess.send_commands('cargo b --release')
        netbricks_sess.send_commands('cd /home/jethros/dev/pvn/utils/contention_diskio')
        netbricks_sess.send_commands('cargo b --release')

        netbricks_sess.send_commands('cd /home/jethros/dev/netbricks/experiments')

        time.sleep(5)
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

        time.sleep(10)
        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        pktgen_sess.kill()
        sys.exit(1)


def p2p_sess_setup(node, trace, nf, epoch):
    p2p_nodes = {
        'provenza': 'seeder',
        'flynn': 'leecher',
        'tao': 'leecher',
        'sanchez': 'leecher',
    }
    p2p_ips = {
        'provenza': '10.200.111.125',
        'flynn': '10.200.111.124',
        'tao': '10.200.111.123',
        'sanchez': '10.200.111.122',
    }

    print("Entering p2p_sess setup for {} as {}".format(node, p2p_nodes[node]))
    try:
        p2p_sess = Screen(node, True)
        print("p2p session for {} is spawned".format(node))

        p2p_sess.send_commands('bash')
        p2p_sess.enable_logs(node + "--" + trace + "_" + nf + ".log")
        p2p_sess.send_commands('ssh jethros@' + p2p_ips[node])
        p2p_sess.send_commands('cd /home/jethros/dev/pvn/utils/p2p_expr')
        p2p_sess.send_commands('git pull')

        time.sleep(3)
        return p2p_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        p2p_sess.kill()
        sys.exit(1)


def run_p2p_node(typ, sess, setup, epoch):
    if typ == "leecher":
        cmd_str = "./p2p_run_leecher.py " + str(setup) + " " + str(epoch)
        print("Run P2P Leecher \n\tCmd: {}".format(cmd_str))
        sess.send_commands(cmd_str)

        time.sleep(5)
    else:
        print("Unknown type: {}".format(typ))


def run_pktgen(sess, trace, setup):
    if trace in ['64B', '128B', '256B', '512B', '524B', '1280B', '1518B']:
        # never here
        size = trace[:-1]
        cmd_str = "sudo ./run_pktgen.sh " + trace
        set_rate_str = "set 0 rate 50"
        set_size_str = "set 0 size " + size
        start_str = "start 0"

        time.sleep(10)
        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_rate_str, set_size_str, start_str)

        time.sleep(5)
        print("Pktgen\nRUN pktgen")
    else:
        cmd_str = "sudo ./run_pktgen.sh " + trace
        print(cmd_str)
        set_port_str = "set 0 rate " + str(setup)
        start_str = "start 0"

        time.sleep(5)
        # print("Pktgen\nStart with cmd: {}".format(cmd_str))
        sess.send_commands(cmd_str, set_port_str, start_str)

        time.sleep(5)
        print("Pktgen\nRUN pktgen")


def run_netbricks(sess, trace, nf, epoch, setup, cpu, mem, diskio):
    # for tlsv and rdr
    #   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup	$5=cpu $6=mem $7=diskio
    cmd_str = "sudo ./run_pvnf_contend.sh " + trace + " " + nf + " " + str(epoch) + " " + setup + " " + cpu + " " + mem + " " + diskio
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_netbricks_rdr(sess, trace, nf, epoch, setup, cpu, mem, diskio, disk):
    # for rdr
    #   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup	$5=cpu $6=mem $7=diskio $8=disk
    cmd_str = "sudo ./run_pvnf_contend.sh " + trace + " " + nf + " " + str(epoch) + " " + setup + " " + cpu + " " + mem + " " + diskio + " " + disk
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_netbricks_xcdr(sess, trace, nf, epoch, setup, port1, port2, expr_num, cpu, mem, diskio):
    #   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=cpu $6=mem $7=diskio $8=port $9=expr_num
    cmd_str = "sudo ./run_pvnf_contend.sh " + trace + " " + nf + " " + str(epoch) + " " + setup + " " + cpu + " " + mem + " " + diskio + " " + str(
        7419) + " " + expr_num
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_netbricks_p2p(sess, trace, nf, epoch, setup, p2p_type, cpu, mem, diskio):
    #   $ ./run_pvnf_contend.sh $1=trace $2=nf $3=iter $4=setup $5=cpu $6=mem $7=diskio $8=p2p_type
    cmd_str = "sudo ./run_pvnf_contend.sh " + trace + " " + nf + " " + str(
        epoch) + " " + setup + " " + cpu + " " + mem + " " + diskio + " " + p2p_type

    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def sess_destroy(sess):
    if sess.exists:
        sess.kill()


def sess_reboot(sess):
    cmd_str = "sudo reboot"
    sess.send_commands(cmd_str)


def p2p_cleanup(typ, sess):
    if typ == "netbricks":
        p2p_cmd_str = "sudo ./misc/p2p_cleanup_nb.sh"
        sess.send_commands(p2p_cmd_str)
        print("NetBricks P2P cmd: {}".format(p2p_cmd_str))
        time.sleep(1)

    elif typ == "leecher":
        cmd_str = "sudo ./p2p_cleanup_leecher.sh "
        sess.send_commands(cmd_str)
        print("Leecher P2P clean up with cmd: {}".format(cmd_str))
        time.sleep(3)

        config_str = "./p2p_config_leecher.sh "
        sess.send_commands(config_str)
        print("Leecher P2P config with cmd: {}".format(config_str))
        time.sleep(15)
    else:
        print("Unknown p2p node type {}".format(typ))


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
        # expr: app_tlsv
        print("Running experiments that for {} application NF".format(expr))
        # app_rdr_t, app_p2p_t
        for nf in contend.pvn_nf[expr]:
            # nf: 'pvn-tlsv-transform-app',
            # we are running the regular NFs
            #
            # config the pktgen sending rate
            for contention in contend.setup:
                pktgen_sess = pktgen_sess_setup(contend.trace[expr], nf, contend.sending_rate[expr][contend.nf_set[expr]])

                if nf == "pvn-tlsv-transform-app":
                    tls_trace = contend.fetch_tlsv_trace(contend.nf_set[expr])
                    run_pktgen(pktgen_sess, tls_trace, contend.sending_rate[expr][contend.nf_set[expr]])
                else:
                    run_pktgen(pktgen_sess, contend.trace[expr], contend.sending_rate[expr][contend.nf_set[expr]])

                # epoch from 0 to 9
                for epoch in range(contend.num_of_epoch):
                    netbricks_sess = netbricks_sess_setup(contend.trace[expr], nf, epoch)

                    # run clean up for p2p nf before experiment
                    if nf in contend.p2p_nf_list:
                        # the setup is the number of images
                        leecher1_sess = p2p_sess_setup('flynn', contend.trace[expr], nf, epoch)
                        leecher2_sess = p2p_sess_setup('tao', contend.trace[expr], nf, epoch)
                        leecher3_sess = p2p_sess_setup('sanchez', contend.trace[expr], nf, epoch)

                        # run clean up for p2p nf before experiment
                        p2p_cleanup("netbricks", netbricks_sess)
                        p2p_cleanup("leecher", leecher1_sess)
                        p2p_cleanup("leecher", leecher2_sess)
                        p2p_cleanup("leecher", leecher3_sess)
                        time.sleep(10)
                    elif nf in contend.xcdr_nf_list:
                        xcdr_cleanup(netbricks_sess)
                        time.sleep(10)
                    elif nf in contend.rdr_nf_list:
                        rdr_cleanup(netbricks_sess)
                        time.sleep(10)

                    # Actual RUN
                    if nf in contend.xcdr_nf_list:
                        expr_num = epoch * 6 + int(contend.nf_set[expr]) * 2
                        port2 = contend.xcdr_port_base + expr_num
                        run_netbricks_xcdr(netbricks_sess, contend.trace[expr], nf, epoch, contend.nf_set[expr], str(port2 - 1), str(port2),
                                           str(expr_num), contention[0], contention[1], contention[2])
                    elif nf in contend.p2p_nf_list:
                        # Actual RUN
                        #
                        run_p2p_node('leecher', leecher1_sess, contend.leecher_set[contend.nf_set[expr]], epoch)
                        run_p2p_node('leecher', leecher2_sess, contend.leecher_set[contend.nf_set[expr]], epoch)
                        run_p2p_node('leecher', leecher3_sess, contend.leecher_set[contend.nf_set[expr]], epoch)
                        time.sleep(30)
                        run_netbricks_p2p(netbricks_sess, contend.trace[expr], nf, epoch, contend.nf_set[expr], "app_p2p-controlled", contention[0],
                                          contention[1], contention[2])
                    elif nf in contend.rdr_nf_list:
                        run_netbricks_rdr(netbricks_sess, contend.trace[expr], nf, epoch, contend.nf_set[expr], contention[0], contention[1],
                                          contention[2], 'hdd')
                        # run_netbricks_rdr(netbricks_sess, contend.trace[expr], nf, epoch, contend.nf_set[expr], contention[0], contention[1],
                        #                   contention[2], 'ssd')
                    else:
                        run_netbricks(netbricks_sess, contend.trace[expr], nf, epoch, contend.nf_set[expr], contention[0], contention[1],
                                      contention[2])

                    # run clean up for p2p nf before experiment
                    if nf in contend.p2p_nf_list:
                        time.sleep(contend.expr_wait_time)
                        time.sleep(30)
                        # run clean up for p2p nf before experiment
                        p2p_cleanup("netbricks", netbricks_sess)
                        p2p_cleanup("leecher", leecher1_sess)
                        p2p_cleanup("leecher", leecher2_sess)
                        p2p_cleanup("leecher", leecher3_sess)
                        time.sleep(15)

                        sess_destroy(leecher1_sess)
                        sess_destroy(leecher2_sess)
                        sess_destroy(leecher3_sess)

                        time.sleep(5)
                    elif nf in contend.xcdr_nf_list:
                        time.sleep(contend.expr_wait_time)
                        time.sleep(30)
                        xcdr_cleanup(netbricks_sess)
                        time.sleep(5)
                    elif nf in contend.rdr_nf_list:
                        time.sleep(contend.expr_wait_time)
                        time.sleep(30)
                        rdr_cleanup(netbricks_sess)
                        time.sleep(5)
                    elif nf in contend.pvn_nf_list:
                        time.sleep(contend.expr_wait_time)
                    else:
                        print("Unknown nf?")
                        sys.exit(1)

                    sess_destroy(netbricks_sess)
                    # sess_destroy(netbricks_sess)
                    time.sleep(5)

                sess_destroy(pktgen_sess)
                time.sleep(10)


print(contend.nf_list)  # just run all
main(contend.nf_list)  # just run all

print("All experiment finished {}".format(contend.nf_list))

# FIXME: we want to reboot here
