#!/bin/bash
rm -f /data/tcpdump-ats.pcap
tcpdump -i any -s 0 -U -w /data/tcpdump-ats.pcap tcp port 80 &

/opt/trafficserver/bin/traffic_server
