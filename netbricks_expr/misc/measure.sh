#!/bin/bash


if [ $@ == 'pvn-transcoder-transform-app' ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh faktory
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory

elif  [ $@ == 'pvn-transcoder-groupby-app' ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh faktory
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh faktory

elif [ $@ == "pvn-p2p-transform-app" ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh deluge
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge

elif [ $@ == "pvn-p2p-groupby-app" ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh deluge
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh deluge

elif [ $@ == "pvn-rdr-transform-app" ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh chrom
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom

elif [ $@ == "pvn-rdr-groupby-app" ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh chrom
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh chrom

elif [ $@ == "pvn-tlsv-transform-app" ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn

elif [ $@ == "pvn-tlsv-groupby-app" ]; then
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/ptop.sh pvn
	/home/jethros/dev/pvn/utils/netbricks_expr/misc/pmem.sh pvn

else
	echo "unknown type"
fi
