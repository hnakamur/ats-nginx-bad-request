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

COPY trafficserver ${SRC_DIR}/trafficserver
WORKDIR ${SRC_DIR}/trafficserver
ARG BUILD_DIR=/src/trafficserver/build
RUN cmake -B ${BUILD_DIR} -G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/opt/trafficserver \
	-DCMAKE_INSTALL_BINDIR=bin \
	-DCMAKE_INSTALL_SBINDIR=bin \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_INSTALL_LIBEXECDIR=lib/modules \
	-DCMAKE_INSTALL_SYSCONFDIR=etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=var \
	-DCMAKE_INSTALL_RUNSTATEDIR=var/run \
	-DCMAKE_INSTALL_DATAROOTDIR=share \
	-DCMAKE_INSTALL_DATADIR=share/data \
	-DCMAKE_INSTALL_DOCDIR=share/doc \
	-DCMAKE_INSTALL_LOGDIR=var/log \
	-DCMAKE_INSTALL_CACHEDIR=var/cache \
	-DBUILD_EXPERIMENTAL_PLUGINS=ON \
	-DENABLE_MAXMIND_ACL=ON \
	-DENABLE_URI_SIGNING=ON \
	-DENABLE_JEMALLOC=ON \
	-DENABLE_AUTEST=ON
RUN cmake --build ${BUILD_DIR} --parallel --verbose

USER root
RUN cmake --install ${BUILD_DIR}
COPY logging.yaml remap.config records.yaml /opt/trafficserver/etc/

RUN useradd -m -d /opt/trafficserver -s /bin/bash trafficserver
RUN chown -R trafficserver:trafficserver /opt/trafficserver/var

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump

RUN mkdir /data
RUN ln -s /data/proxy.ltsv.log /opt/trafficserver/var/log/
RUN ln -s /data/ats-diags.log /opt/trafficserver/var/log/diags.log
RUN ln -s /data/ats-error.log /opt/trafficserver/var/log/error.log
COPY startup.sh /usr/local/bin/

CMD ["/usr/local/bin/startup.sh"]
