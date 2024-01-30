FROM nginx:1.25.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump

COPY nginx.conf /etc/nginx/

COPY startup.sh /usr/local/bin/

CMD ["/usr/local/bin/startup.sh"]
