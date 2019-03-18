ARG BASE_IMAGE=alpine:latest

FROM ${BASE_IMAGE}

ARG VERSION=.

# Build libtorrent-rasterbar[-dev]
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk add --no-cache                       boost-system g++ gcc musl openssl && \
    apk add --no-cache --virtual .build-deps autoconf automake boost-dev file g++ gcc git libtool make openssl-dev && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${LIBTORRENT_VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    # https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
    # https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
    ./autotool.sh && \
    ./configure --disable-debug --enable-encryption --with-libgeoip=system CXXFLAGS=-std=c++11 && \
    make clean && \
    make -j$(nproc) && \
    make uninstall && \
    make install-strip && \
    # Remove intermediary files
    cd && \
    apk del --purge .build-deps && \
    rm -rf /tmp/*

RUN set -euo pipefail && \
    apk add --no-cache coreutils && \
    find / -name libtorrent* && \
    du -h * | sort -h | tac | head -10
