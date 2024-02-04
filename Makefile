run:
	rm -f *.log *.pcap
	docker compose up -d --build
	docker compose wait hey
	docker compose logs hey
	docker compose logs --no-log-prefix hey > hey.log
	docker compose logs --no-log-prefix ats > ats.log
	docker compose logs --no-log-prefix nginx > nginx.log
	docker compose stop --timeout 3
	sudo chown $${USER}: *.log *.pcap
	zstd -z -19 --rm ats.log

.PHONY: run
