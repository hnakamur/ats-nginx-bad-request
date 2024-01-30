#!/bin/bash
tcpdump -i any -s 0 -U -w /tmp/tcpdump-ats.pcap tcp port 80 &

/opt/trafficserver/bin/traffic_server
