#!/bin/bash
if [ $# -ne 1 ]; then
  >2 echo Usage: $0 port
  exit 2
fi

port="$1"
grep "remote_port:$port" access.log > "access.port$port.log"

tcpdump -r "tcpdump-ats.pcap" -w "tcpdump-ats.port$port.pcap" port "$port"
tcpdump -A -n -vvv -r "tcpdump-ats.port$port.pcap" > "tcpdump-ats.port$port.log"

tcpdump -r "tcpdump-nginx.pcap" -w "tcpdump-nginx.port$port.pcap" port "$port"
tcpdump -A -n -vvv -r "tcpdump-nginx.port$port.pcap" > "tcpdump-nginx.port$port.log"
