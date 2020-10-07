from subprocess import *
import os
import sys
import shutil
from urllib.parse import urlparse

http = 'http://'
https = 'https://'
#call(['python3', 'get_web.py'])
FNULL = open(os.devnull, 'w')
web_list = open('web_urls.txt', 'r').read().split('\n')
while web_list[-1] == "":
    del web_list[-1]

mmwebrecord = '/usr/bin/mm-webrecord'
mmlink = '/usr/bin/mm-link'
repo = 'tmp'


i = 0
for web in web_list:
    i += 1
    sys.stdout.flush()
    url = http + web
    print(str(i) + " record: " + url)
    # call(['rm', '-rf', os.path.join(repo, web)])
    try:
        call([mmwebrecord, os.path.join(repo, web), mmlink, 'trace_file', 'trace_file', '--', 'python3', 'chrome.py', url, 'record'],  env=os.environ.copy(), stdout=FNULL, stderr=STDOUT )
        shutil.copyfile('tmp', os.path.join(repo, web, 'ttfb.txt'))
        # call(['python3', 'parse.py', os.path.join(repo, web)])
    except Exception as e:
        call(['pkill', 'chromium'])
        print("Something wrong with recording {}: {}".format(web, str(e)) )

