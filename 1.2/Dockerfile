# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.11.6@sha256:39eda93d15866957feaee28f8fc5adb545276a64147445c64992ef69804dbf01

ARG VERSION=1.2.[0-9]+

# Build libtorrent-rasterbar-dev
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-system libgcc libstdc++ openssl py2-pip && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    for PYTHON_VERSION in $(seq 2 3); do \
        apk --update add --no-cache                               boost-python${PYTHON_VERSION} && \
        apk --update add --no-cache --virtual python-dependencies python${PYTHON_VERSION}-dev && \
        ./configure \
            --prefix=/usr \
            --with-libiconv \
            --enable-python-binding \
            --with-boost-python="$(ls -1 /usr/lib/libboost_python${PYTHON_VERSION/2/}*.so* | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
            PYTHON="$(which python${PYTHON_VERSION})" && \
        make -j$(nproc) && \
        make install-strip && \
        apk del --purge python-dependencies; \
    done && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
