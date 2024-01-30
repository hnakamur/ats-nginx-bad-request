FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump \
    build-essential make libssl-dev libpcre3-dev zlib1g-dev

RUN mkdir -p /src/nginx

RUN useradd -m -d /src/nginx -s /bin/bash nginx

COPY nginx/ /src/nginx/

WORKDIR /src/nginx
RUN export CFLAGS="-g -O2 -ffile-prefix-map=/src/nginx=. -flto=auto -ffat-lto-objects -fstack-protector-strong -fstack-protector-strong -Wall -Wformat=2 -Werror=unused-variable -Wno-error=conversion -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC -Wno-missing-field-initializers -Wno-implicit-fallthrough"; \
    export LDFLAGS="-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie -lm -ldl"; \
    ./auto/configure \
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-compat \
		--with-file-aio \
		--with-threads \
		--with-http_realip_module \
		--with-http_ssl_module \
		--with-stream \
		--with-stream_realip_module \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-cc-opt="${CFLAGS}" \
		--with-ld-opt="${LDFLAGS}" \
		--without-pcre2
RUN make -j
RUN make install

RUN mkdir -p /etc/nginx/conf.d /var/www/html /var/cache/nginx
RUN chown nginx:nginx /var/cache/nginx

COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/
COPY *.html /var/www/html/

COPY startup.sh /usr/local/bin/

# RUN rm -f /var/log/nginx/access.log /var/log/nginx/error.log

CMD ["/usr/local/bin/startup.sh"]
