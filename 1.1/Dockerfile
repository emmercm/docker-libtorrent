# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.9.4@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6

ARG VERSION=1.1.[0-9]+
ARG PYTHON_VERSION=3

COPY test.sh /

# Build libtorrent-rasterbar-dev
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              ${PYTHON_VERSION:+boost-python${PYTHON_VERSION/2/}} boost-system libgcc libstdc++ openssl && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev ${PYTHON_VERSION:+python${PYTHON_VERSION}-dev} && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $(git tag --sort=-version:refname | grep "${VERSION}" | head -1) && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    ./configure \
        --prefix=/usr \
        --disable-debug \
        --enable-encryption \
        --with-libiconv \
        ${PYTHON_VERSION:+--enable-python-binding --with-boost-python="$(ls -1 /usr/lib/libboost_python${PYTHON_VERSION}*-mt.so* | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" PYTHON="$(which python${PYTHON_VERSION})"} && \
    make -j$(nproc) && \
    make install-strip && \
    # Test Python binding (before Python is uninstalled)
    if [[ "${PYTHON_VERSION}" != "" ]]; then python${PYTHON_VERSION} -c 'import libtorrent' || exit 1; fi && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    # Test build (after all uninstalls)
    /test.sh && \
    rm /test.sh

RUN apk --update add coreutils binutils
RUN du -ch -d 10 / | sort -rh | head -100
RUN find / -type f -exec du -ah {} + | sort -rh | head -100
RUN size --totals /usr/lib/libtorrent-rasterbar.a | sort -n
RUN ldd /usr/lib/libtorrent-rasterbar.so
