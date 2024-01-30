#!/bin/bash
tcpdump -i any -s 0 -U -w /tmp/tcpdump-nginx.pcap tcp port 80 &

nginx -g 'daemon off;'
