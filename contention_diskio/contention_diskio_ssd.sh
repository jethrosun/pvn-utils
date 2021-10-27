#!/bin/bash

#!/bin/bash

# the script will be run every 5 seconds

if [[ $1 -eq 0 ]]; then
	echo "no disk I/O contention";
	exit;
elif [[ $1 -eq 1 ]]; then
	# the script will be run every 5 seconds so it is 5 sec * X MB/second
	FILE_IO_PER_SECOND=1
elif [[ $1 -eq 2 ]]; then
	FILE_IO_PER_SECOND=20
elif [[ $1 -eq 3 ]]; then
	FILE_IO_PER_SECOND=200
else
	echo "Contention param is wrong, $1"
	exit;
fi
echo "File IO per second is $FILE_IO_PER_SECOND"

if [[ $2 -eq 3 ]]; then
	:
elif [[ $2 -eq 4 ]]; then
	:
else
	echo "Core param is wrong, $2"
	exit;
fi
echo "Core is $2"

cd /home/jethros/data
target="tmp$2"
mkdir -p $target

# start=`date +%s`

for N in $(seq 1 $FILE_IO_PER_SECOND); do
	taskset -c $2 head -c 1M </dev/urandom >$target/$N
done;

# end=`date +%s`
# runtime=$((end-start))
# echo "Total time is $runtime"
