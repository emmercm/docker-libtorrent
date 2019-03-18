# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3

ARG BASE_IMAGE=alpine:latest

FROM ${BASE_IMAGE}

ARG VERSION=.

# Build libtorrent-rasterbar[-dev]
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-system libcrypto1.1 libgcc libssl1.1 libstdc++ && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev file g++ gcc git libtool make openssl-dev && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    ./configure --disable-debug --enable-encryption --with-libgeoip=system CXXFLAGS=-std=c++11 && \
    make clean && \
    make -j$(nproc) && \
    make uninstall && \
    make install-strip && \
    # Remove intermediary files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

# Test build
RUN set -euo pipefail && \
    apk --update add --no-cache --virtual test-dependencies musl-utils && \
    for FILE in $(find /usr/local/lib -name libtorrent-rasterbar.so*); do \
        for LIB in $(ldd "${FILE}" | awk '{print $3}'); do \
            if [[ ! -e "${LIB}" ]]; then \
                echo "Missing library: ${LIB}" && exit 1 \
            ; fi \
        ; done \
    ; done && \
    apk del --purge test-dependencies && \

# Debug
RUN set -euo pipefail && \
    apk --update add --no-cache coreutils && \
    du -h * 2> /dev/null | sort -h | tac | head -10
