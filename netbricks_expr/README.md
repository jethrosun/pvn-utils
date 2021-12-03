# NetBricks configuration 


# PS to collect long running processes' stat
# https://unix.stackexchange.com/questions/215671/can-i-use-ps-aux-along-with-o-etime
# https://unix.stackexchange.com/questions/58539/top-and-ps-not-showing-the-same-cpu-result
#
# ps -e -o user,pid,%cpu,%mem,vsz,rss,start,time,command,etime,etimes,euid --sort=-%mem




## about core configuration

NB config core 3 means the core 4 in htop.
