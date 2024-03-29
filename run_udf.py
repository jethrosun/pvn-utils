#!/usr/bin/env python

import sys
import time
import getpass as gt

import nf_config as conf
from screenutils import Screen, list_screens

current_user = gt.getuser()

def netbricks_sess_setup(trace, nf, epoch):
    print("Entering netbricks_sess setup")
    try:
        netbricks_sess = Screen("netbricks", True)
        print("netbricks session is spawned")

        netbricks_sess.send_commands('bash')
        netbricks_sess.enable_logs(
            "netbricks--" + trace + "_" + nf + "_" + str(epoch) + ".log")
        netbricks_sess.send_commands('ssh ' + current_user + '@tuco')
        # netbricks_sess.send_commands('cd /home/' + current_user + '/dev/pvn/utils/faktory_srv')
        # netbricks_sess.send_commands('cargo b --release')
        netbricks_sess.send_commands(
            'cd /home/' + current_user + '/dev/netbricks/experiments')

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
            'cd /home/' + current_user + '/dev/pktgen-dpdk/experiments')

        time.sleep(20)
        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        pktgen_sess.kill()
        sys.exit(1)


def p2p_sess_setup(node, trace, nf, epoch):
    p2p_nodes = {
        'bt1': 'seeder',
        'bt2': 'leecher',
        'bt3': 'leecher',
        'bt4': 'leecher',
    }
    p2p_ips = {
        'bt1': '10.200.111.125',
        'bt2': '10.200.111.124',
        'bt3': '10.200.111.123',
        'bt4': '10.200.111.122',
    }

    print("Entering p2p_sess setup for {} as {}".format(node, p2p_nodes[node]))
    try:
        p2p_sess = Screen(node, True)
        print("p2p session for {} is spawned".format(node))

        p2p_sess.send_commands('bash')
        p2p_sess.enable_logs(node + "--" + trace + "_" + nf + ".log")
        p2p_sess.send_commands('ssh ' + current_user + '@' + p2p_ips[node])
        p2p_sess.send_commands('cd /home/' + current_user + '/dev/pvn/utils/p2p_expr')
        p2p_sess.send_commands('git pull')

        time.sleep(5)
        return p2p_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        p2p_sess.kill()
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


# def run_netbricks(sess, trace, nf, epoch, setup):
def run_netbricks(sess, batch, schedule, epoch, setup):
    cmd_str = "sudo ./run_udf_schedule.sh " + batch + \
        " " + schedule + " " + str(epoch) + " " + setup
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_p2p_node(typ, sess, node, batch, sched):
    if typ == "leecher":
        cmd_str = "./leecher_run.sh " + \
            str(node) + " " + str(batch) + " " + str(sched)
        print("Run P2P Leecher \n\tCmd: {}".format(cmd_str))
        sess.send_commands(cmd_str)

        time.sleep(5)
    else:
        print("Unknown type: {}".format(typ))


def sess_destroy(sess):
    if sess.exists:
        sess.kill()


def sess_reboot(sess):
    cmd_str = "sudo reboot"
    sess.send_commands(cmd_str)


# setup only once at the beginning
def p2p_setup(typ, sess):
    if typ == "netbricks":
        p2p_cmd_str = "sudo ./misc/nb_setup.sh"
        sess.send_commands(p2p_cmd_str)
        print("NetBricks P2P cmd: {}".format(p2p_cmd_str))
        time.sleep(5)

    elif typ == "leecher":
        config_str = "./leecher_setup.sh "
        sess.send_commands(config_str)
        print("Leecher P2P setup with cmd: {}".format(config_str))
        time.sleep(5)
    else:
        print("Unknown p2p node type {}".format(typ))


def p2p_cleanup(typ, sess):
    if typ == "netbricks":
        p2p_cmd_str = "sudo ./misc/nb_cleanup.sh"
        sess.send_commands(p2p_cmd_str)
        print("NetBricks P2P cmd: {}".format(p2p_cmd_str))
        time.sleep(5)

    elif typ == "leecher":
        cmd_str = "sudo ./leecher_cleanup.sh "
        sess.send_commands(cmd_str)
        print("Leecher P2P clean up with cmd: {}".format(cmd_str))
        time.sleep(5)

    else:
        print("Unknown p2p node type {}".format(typ))


def rdr_cleanup(sess):
    cmd_str = "sudo ./misc/rdr_cleanup.sh "
    print("Extra clean up for RDR with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def main(batch_list, schedule_list):
    expr = 'udf_schedule'  # we only use one expr anyway
    nf = conf.pvn_nf[expr][0]
    for batch in batch_list:
        print("Running experiments that for {} application NF".format(expr))
        for schedule in schedule_list:
            sending_rate = 10
            pktgen_sess = pktgen_sess_setup(conf.trace[expr], nf, sending_rate)
            run_pktgen(pktgen_sess, conf.trace[expr], sending_rate)

            # setup here maps to node (1,2,3)
            for node in conf.udf_node_list:
                # epoch from 0 to 9
                for epoch in range(conf.sched_num_of_epoch):
                    netbricks_sess = netbricks_sess_setup(
                        conf.trace[expr], nf, epoch)

                    leecher1_sess = p2p_sess_setup('bt2', conf.trace[expr], nf, epoch)
                    leecher2_sess = p2p_sess_setup('bt3', conf.trace[expr], nf, epoch)
                    leecher3_sess = p2p_sess_setup('bt4', conf.trace[expr], nf, epoch)

                    if epoch == 0:
                        p2p_setup("netbricks", netbricks_sess)
                        p2p_setup("leecher", leecher1_sess)
                        p2p_setup("leecher", leecher2_sess)
                        p2p_setup("leecher", leecher3_sess)

                    # run clean up for p2p nf before experiment
                    p2p_cleanup("netbricks", netbricks_sess)
                    p2p_cleanup("leecher", leecher1_sess)
                    p2p_cleanup("leecher", leecher2_sess)
                    p2p_cleanup("leecher", leecher3_sess)

                    rdr_cleanup(netbricks_sess)
                    # xcdr_cleanup(netbricks_sess)
                    time.sleep(5)

                    # Actual RUN
                    run_p2p_node('leecher', leecher1_sess, node, batch, schedule)
                    run_p2p_node('leecher', leecher2_sess, node, batch, schedule)
                    run_p2p_node('leecher', leecher3_sess, node, batch, schedule)

                    run_netbricks(netbricks_sess, batch, schedule, epoch, node)

                    time.sleep(conf.udf_schedule_time)

                    # run clean up for p2p nf before experiment
                    p2p_cleanup("netbricks", netbricks_sess)
                    p2p_cleanup("leecher", leecher1_sess)
                    p2p_cleanup("leecher", leecher2_sess)
                    p2p_cleanup("leecher", leecher3_sess)

                    time.sleep(15)

                    sess_destroy(leecher1_sess)
                    sess_destroy(leecher2_sess)
                    sess_destroy(leecher3_sess)

                    rdr_cleanup(netbricks_sess)
                    # xcdr_cleanup(netbricks_sess)
                    time.sleep(5)

                    sess_destroy(netbricks_sess)
                    time.sleep(5)

            sess_destroy(pktgen_sess)
            time.sleep(30)


main(conf.batch_list, conf.schedule_list)  # rdr, xcdr
print("All experiment finished. NF {}, Batch {}, Schedule {}".format(
    conf.udf_schedule, conf.batch_list, conf.schedule_list))
