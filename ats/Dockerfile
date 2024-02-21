# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Apapted from
# https://github.com/apache/trafficserver/blob/e4ff6cab0713f25290a62aba74b8e1a595b7bc30/ci/docker/deb/Dockerfile#L46-L58
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata apt-utils curl && \
    # Compilers
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    ccache pkgconf bison flex gettext libc++-dev \
    g++ cmake ninja-build \
    # tools to create deb packages
    debhelper dpkg-dev lsb-release xz-utils \
    # Various other tools
    dpkg-dev git distcc file wget openssl hwloc intltool-debian && \
    # Devel packages that ATS needs
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    libssl-dev libexpat1-dev libpcre3-dev libcap-dev \
    libhwloc-dev libunwind8 libunwind-dev zlib1g-dev \
    tcl-dev tcl8.6-dev libjemalloc-dev libluajit-5.1-dev liblzma-dev \
    libhiredis-dev libbrotli-dev libncurses-dev libgeoip-dev libmagick++-dev \
    libmaxminddb-dev libjansson-dev libcjose-dev \
    python3 python3-pip python3-virtualenv

# Note: install pipenv as root user since root privilege is needed to run all tests in autest.
RUN pip3 install pipenv

ARG SRC_DIR=/src
ARG BUILD_USER=build
RUN useradd -m -d ${SRC_DIR} -s /bin/bash ${BUILD_USER}

USER ${BUILD_USER}
WORKDIR ${SRC_DIR}
RUN mkdir ${SRC_DIR}/trafficserver

ARG GIT_COMMIT=b4e3c73354d2a104ed6f00379eeb9f121a85e8bb
RUN curl -sSL https://github.com/apache/trafficserver/archive/${GIT_COMMIT}.tar.gz | tar zxf - --strip-component=1 -C ${SRC_DIR}/trafficserver
WORKDIR ${SRC_DIR}/trafficserver
ARG BUILD_DIR=/src/trafficserver/build
RUN autoreconf -if
RUN ./configure \
    --enable-layout=opt \
	--prefix=/opt/trafficserver \
	--includedir=/usr/include \
	--datarootdir=/usr/share \
	--datadir=/usr/share \
	--infodir=/usr/share/info \
	--localedir=/usr/share/locale \
	--mandir=/usr/share/man \
	--docdir=/usr/share/doc/trafficserver \
	--htmldir=/usr/share/doc/trafficserver \
	--dvidir=/usr/share/doc/trafficserver \
	--pdfdir=/usr/share/doc/trafficserver \
	--psdir=/usr/share/doc/trafficserver \
	--exec-prefix=/usr \
	--sysconfdir=/opt/trafficserver/etc --libdir=/usr/lib/trafficserver \
	--localstatedir=/opt/trafficserver/var \
	--libexecdir=/usr/lib/trafficserver/modules \
	--with-user=root --with-group=root --disable-silent-rules \
	--enable-experimental-plugins --enable-32bit-build \
	--with-brotli=/usr/include
RUN make -j

USER root
RUN make install
COPY logging.yaml remap.config records.config /opt/trafficserver/etc/

RUN useradd -m -d /opt/trafficserver -s /bin/bash trafficserver
RUN chown -R trafficserver:trafficserver /opt/trafficserver/var

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump

RUN mkdir /data
RUN ln -s /data/proxy.ltsv.log /opt/trafficserver/var/logs/
RUN ln -s /data/ats-diags.log /opt/trafficserver/var/logs/diags.log
RUN ln -s /data/ats-error.log /opt/trafficserver/var/logs/error.log
COPY startup.sh /usr/local/bin/

CMD ["/usr/local/bin/startup.sh"]
