# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3

ARG BASE_IMAGE=alpine:latest

FROM ${BASE_IMAGE}

ARG VERSION=.
ARG PYTHON_VERSION=3

COPY test.sh /

# Build libtorrent-rasterbar[-dev]
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-system libgcc libstdc++ openssl && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev python${PYTHON_VERSION}-dev && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    PYTHON3=$(which python3) && \
    PYTHON3_VERSION=$(python3 --version | sed -n 's/Python \([0-9]*\.[0-9]*\)\.[0-9]*/\1/p') && \
    ./configure \
        CXXFLAGS="-std=c++11 -Wno-deprecated-declarations" \
        --disable-debug \
        --disable-geoip \
        --enable-encryption \
        --enable-python-binding && \
    make -j$(nproc) && \
    make install-strip && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build
    /test.sh && \
    rm /test.sh
