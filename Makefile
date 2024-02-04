run:
	rm -f *.log *.pcap
	docker compose up -d --build
	docker compose wait hey
	docker compose logs hey
	docker compose logs --no-log-prefix hey > hey.log
	docker compose stop --timeout 2
	sudo chown $${USER}: *.log *.pcap

.PHONY: run
