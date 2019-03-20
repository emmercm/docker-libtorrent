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
    BOOST_VERSION="" && \
    if [[ "${VERSION} | grep '1\.0\.'" != "" ]]; then \
        BOOST_VERSION="=1.65.1" \
    ;fi \
    apk --update add --no-cache                              boost-system${BOOST_VERSION} libcrypto1.1 libgcc libssl1.1 libstdc++ && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev${BOOST_VERSION} file g++ gcc geoip-dev git libtool make openssl-dev && \
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
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build
    if [[ "$(find /usr/local/lib -name libtorrent-rasterbar.so*)" == "" ]]; then \
        echo "Failed to find /usr/local/lib/libtorrent-rasterbar.so*" >&2 && exit 1 \
    ;fi && \
    for FILE in $(find /usr/local/lib -name libtorrent-rasterbar.so*); do \
        for LIB in $(ldd "${FILE}" | awk '{print $3}' | grep -v "^ldd$"); do \
            if [[ ! -e "${LIB}" ]]; then \
                echo "Missing library: ${LIB}" >&2 && exit 1 \
            ;fi \
        ;done \
    ;done
