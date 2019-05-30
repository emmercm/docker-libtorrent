# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:latest

ARG VERSION=0.16.[0-9]+

COPY test.sh /

# Build libtorrent-rasterbar-dev
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-system libgcc libstdc++ openssl && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    ./configure \
        CFLAGS="-Wno-deprecated-declarations" \
        CXXFLAGS="-Wno-deprecated-declarations" \
        --prefix=/usr \
        --disable-debug \
        --disable-geoip \
        --enable-encryption \
        --with-libiconv && \
    make -j$(nproc) && \
    make install && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build (after all uninstalls)
    /test.sh && \
    rm /test.sh
