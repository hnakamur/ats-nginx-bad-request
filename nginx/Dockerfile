FROM nginx:1.24.0-bullseye

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump

COPY nginx.conf /etc/nginx/

COPY startup.sh /usr/local/bin/

RUN rm -f /var/log/nginx/access.log /var/log/nginx/error.log

CMD ["/usr/local/bin/startup.sh"]
