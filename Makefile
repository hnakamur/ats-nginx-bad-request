run:
	docker compose up -d --build
	docker compose wait hey
	docker compose logs hey
	docker compose cp ats:/opt/trafficserver/var/log/proxy.ltsv.log proxy.ltsv.log
	docker compose cp ats:/tmp/tcpdump-ats.pcap tcpdump-ats.pcap
	docker compose cp nginx:/tmp/tcpdump-nginx.pcap tcpdump-nginx.pcap
	docker compose logs --no-log-prefix hey > hey.log
	docker compose logs --no-log-prefix nginx > nginx.log
	docker compose stop

.PHONY: run
