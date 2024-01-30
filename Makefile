run:
	docker compose up -d
	docker compose wait hey
	docker compose cp ats:/opt/trafficserver/var/log/proxy.ltsv.log proxy.ltsv.log
	docker compose stop
	docker compose logs hey

.PHONY: run
