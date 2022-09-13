#!/usr/bin/env python

import sys
import time

import contend_config as contend
from screenutils import Screen


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



def run_pktgen(sess, trace, setup):
    if trace in ['64B', '128B', '256B', '512B', '1280B', '1500B']:
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
    cmd_str = "sudo ./run_pvnf_contend.sh " + trace + " " + nf + " " + str(
        epoch) + " " + setup + " " + cpu + " " + mem + " " + diskio
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
    for expr in expr_list:
        # expr: app_tlsv
        print("Running experiments that for {} application NF".format(expr))
        # app_rdr_t, app_p2p_t
        nf = contend.pvn_nf[expr]
        for trace in contend.pvn_trace[expr]:
            # nf: 'pvn-tlsv-transform-app',
            # we are running the regular NFs
            #
            # config the pktgen sending rate
            for contention in contend.setup:
                pktgen_sess = pktgen_sess_setup(trace, nf, 100)

                if nf == "pvn-tlsv-transform-app":
                    tls_trace = contend.fetch_tlsv_trace(contend.nf_set[expr])
                    run_pktgen(pktgen_sess, tls_trace, 100)
                else:
                    run_pktgen(pktgen_sess, trace, 100)

                # epoch from 0 to 9
                for epoch in range(contend.num_of_epoch):
                    netbricks_sess = netbricks_sess_setup(trace, nf, epoch)

                    # Actual RUN
                    run_netbricks(netbricks_sess, trace, nf, epoch, contend.nf_set[expr],
                                  contention[0], contention[1], contention[2])

                    time.sleep(contend.expr_wait_time)

                    sess_destroy(netbricks_sess)
                    # sess_destroy(netbricks_sess)
                    time.sleep(5)

                sess_destroy(pktgen_sess)
                time.sleep(10)


print(contend.nf_list)  # just run all
main(contend.nf_list)  # just run all

print("All experiment finished {}".format(contend.nf_list))

# FIXME: we want to reboot here
