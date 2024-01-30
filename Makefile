run:
	docker compose up -d
	docker compose wait hey
	docker compose logs hey
	docker compose cp ats:/opt/trafficserver/var/log/proxy.ltsv.log proxy.ltsv.log
	docker compose cp ats:/tmp/tcpdump-ats.pcap tcpdump-ats.pcap
	docker compose cp nginx:/var/log/nginx/access.log access.log
	docker compose cp nginx:/var/log/nginx/error.log nginx-error.log
	docker compose cp nginx:/tmp/tcpdump-nginx.pcap tcpdump-nginx.pcap
	docker compose logs --no-log-prefix hey > hey.log
	docker compose stop

.PHONY: run
