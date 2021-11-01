# Utils to run the experiments for systems

# FIX:

## XCDR
place video transcoding on core 1 not 0

## Run RDR 5 times to figure out the number

## Merge trace

https://docs.oracle.com/cd/E88353_01/html/E37839/mergecap-1.html

mergecap -w pvn_rdr_tlsv -F pcap pvn_rdr.pcap pvn_tlsv.pcap
