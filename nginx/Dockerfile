FROM nginx:1.25.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump

RUN mkdir -p /src/nginx

RUN mkdir -p /etc/nginx/conf.d /var/www/html /var/cache/nginx
RUN chown nginx:nginx /var/cache/nginx

COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/
COPY *.html /var/www/html/

RUN mkdir /data
COPY startup.sh /usr/local/bin/

CMD ["/usr/local/bin/startup.sh"]
