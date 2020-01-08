#!/bin/bash

for trace in tls_handshake_trace.pcap p2p-small.pcap ictf2010.pcap10 ictf2010.pcap14 ictf2010.pcap net-2009-11-18-10:32.pcap net-2009-11-18-17:35.pcap net-2009-11-23-16:54.pcap rdr-browsing.pcap 64B 128B 256B
do
	./run_pktgen.sh $trace
done

