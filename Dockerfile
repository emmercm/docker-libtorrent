# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3

ARG BASE_IMAGE=alpine:latest

FROM ${BASE_IMAGE}

ARG VERSION=[0-9]+.[0-9]+.[0-9]+
ARG PYTHON_VERSION=3

COPY test.sh /

# Build libtorrent-rasterbar-dev
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-system libgcc libstdc++ openssl && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev ${PYTHON_VERSION:+python${PYTHON_VERSION}-dev} && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    ./configure \
        CFLAGS="-Wno-deprecated-declarations" \
        CXXFLAGS="-Wno-deprecated-declarations" \
        --disable-debug \
        --disable-geoip \
        --enable-encryption \
        ${PYTHON_VERSION:+--enable-python-binding PYTHON="$(which python${PYTHON_VERSION})"} && \
    make -j$(nproc) && \
    make install-strip && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build
    /test.sh && \
    rm /test.sh
