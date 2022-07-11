#!/usr/bin/env python

import sys
import time

import nf_config as conf
from nf_config import translate
from screenutils import Screen, list_screens


def netbricks_sess_setup(trace, nf, nf_load):
    #netbricks_sess = netbricks_sess_setup(conf.trace[nf_type], nf, nf_load)
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

        time.sleep(5)
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
        pktgen_sess.send_commands('cd /home/jethros/dev/pktgen-dpdk/experiments')

        time.sleep(5)
        return pktgen_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        pktgen_sess.kill()
        sys.exit(1)


def p2p_sess_setup(node, trace, nf):
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

        time.sleep(5)
        return p2p_sess
    except Exception as err:
        print("Creating screen sessions failed: {}".format(err))
        p2p_sess.kill()
        sys.exit(1)


def run_pktgen(sess, trace, rate):
    cmd_str = "sudo ./run_pktgen.sh " + trace
    print(cmd_str)
    set_port_str = "set 0 rate " + str(rate)
    start_str = "start 0"

    time.sleep(5)
    sess.send_commands(cmd_str, set_port_str, start_str)

    time.sleep(5)
    print("Pktgen\nRUN pktgen")


# def run_netbricks_xcdr_p2p(sess, trace, nf, nf_load):
#     load = ""
#     for l in nf_load:
#         load += l
#         load += ":"
#     cmd_str = "sudo ./run_pvnf_task.sh " + trace + " " + nf + " " + load
#     print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
#     sess.send_commands(cmd_str)


def run_netbricks(sess, trace, nf, nf_load):
    load_str = ""
    for l in nf_load:
        load_str += " "
        load_str += str(l)
    cmd_str = "sudo ./run_pvnf_task.sh " + trace + " " + nf + load_str
    print("Run NetBricks\nTry to run with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_p2p_node(typ, sess, setup):
    epoch = 0
    if typ == "leecher":
        cmd_str = "./p2p_run_leecher.py " + str(setup) + " " + str(epoch)
        print("Run P2P Leecher \n\tCmd: {}".format(cmd_str))
        sess.send_commands(cmd_str)
        time.sleep(5)
    else:
        print("Unknown type: {}".format(typ))


def sess_destroy(sess):
    if sess.exists:
        sess.kill()


def p2p_cleanup(typ, sess):
    if typ == "netbricks":
        p2p_cmd_str = "sudo ./misc/p2p_cleanup_nb.sh"
        sess.send_commands(p2p_cmd_str)
        print("NetBricks P2P cmd: {}".format(p2p_cmd_str))
        time.sleep(10)

    elif typ == "leecher":
        cmd_str = "sudo ./p2p_cleanup_leecher.sh "
        sess.send_commands(cmd_str)
        print("Leecher P2P clean up with cmd: {}".format(cmd_str))
        time.sleep(5)

        config_str = "./p2p_config_leecher.sh "
        sess.send_commands(config_str)
        print("Leecher P2P config with cmd: {}".format(config_str))
        time.sleep(10)
    else:
        print("Unknown p2p node type {}".format(typ))


def rdr_cleanup(sess):
    cmd_str = "sudo ./misc/rdr_cleanup.sh "
    print("Extra clean up for RDR with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def xcdr_cleanup(sess):
    cmd_str = "sudo ./misc/xcdr_cleanup.sh "
    print("Extra clean up for XCDR with cmd: {}".format(cmd_str))
    sess.send_commands(cmd_str)


def run_expr_p2p(expr_list):
    print("non existing")


def run_expr_p2p_ext(expr_list):
    print("non existing")


def run_expr_p2p_controlled(raw_p2p_tasks):
    for raw_task in raw_p2p_tasks:
        print("running controlled")
        nf_type, nf_load, sending_rate= translate(raw_task)
        nf = conf.pvn_nf[nf_type][0]
        # sending_rate = sum(nf_load) * 10

        pktgen_sess = pktgen_sess_setup(raw_task+".pcap", nf, sending_rate)
        run_pktgen(pktgen_sess, raw_task+".pcap", sending_rate)

        # for epoch in range(conf.p2p_num_of_epoch):
        netbricks_sess = netbricks_sess_setup(raw_task+".pcap", nf, nf_load)

        leecher1_sess = p2p_sess_setup('flynn', raw_task+".pcap", nf)
        leecher2_sess = p2p_sess_setup('tao', raw_task+".pcap", nf)
        leecher3_sess = p2p_sess_setup('sanchez', raw_task+".pcap", nf)

        # run clean up for p2p nf before experiment
        p2p_cleanup("netbricks", netbricks_sess)
        p2p_cleanup("leecher", leecher1_sess)
        p2p_cleanup("leecher", leecher2_sess)
        p2p_cleanup("leecher", leecher3_sess)
        rdr_cleanup(netbricks_sess)
        xcdr_cleanup(netbricks_sess)
        time.sleep(10)

        # Actual RUN
        run_p2p_node('leecher', leecher1_sess, nf_load[-1])
        run_p2p_node('leecher', leecher2_sess, nf_load[-1])
        run_p2p_node('leecher', leecher3_sess, nf_load[-1])
        run_netbricks(netbricks_sess, raw_task+".pcap", nf, nf_load)

        time.sleep(conf.expr_wait_time)

        # run clean up for p2p nf before experiment
        p2p_cleanup("netbricks", netbricks_sess)
        p2p_cleanup("leecher", leecher1_sess)
        p2p_cleanup("leecher", leecher2_sess)
        p2p_cleanup("leecher", leecher3_sess)
        rdr_cleanup(netbricks_sess)
        xcdr_cleanup(netbricks_sess)
        time.sleep(10)

        sess_destroy(netbricks_sess)
        sess_destroy(leecher1_sess)
        sess_destroy(leecher2_sess)
        sess_destroy(leecher3_sess)
        time.sleep(5)

        sess_destroy(pktgen_sess)
        time.sleep(10)


def main(raw_p2p_tasks, p2p_types):
    for typ in p2p_types:
        print("Running experiments that for P2P with type {} ".format(typ))
        run_expr_p2p_controlled(raw_p2p_tasks)


main(conf.raw_p2p_tasks, ["app_p2p-controlled"])
print("All experiment finished {}".format(conf.p2p_co))
