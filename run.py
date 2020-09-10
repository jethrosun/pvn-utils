#!/usr/bin/env python

from screenutils import list_screens, Screen
import sys
import time
from app_config import *


main_sess = Screen("main", True)
main_sess.send_commands('bash')
main_sess.send_commands('cd $HOME/dev/pvn/utils/')
main_sess.send_commands('./pvn_app.py')
main_sess.enable_logs("main_expr.log")

print("All experiments are done")
