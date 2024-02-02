#!/bin/bash
rm -f /data/tcpdump-nginx.pcap
tcpdump -i any -s 0 -U -w /data/tcpdump-nginx.pcap tcp port 80 &

nginx -g 'daemon off;'
