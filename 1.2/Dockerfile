# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.10.0@sha256:ca1c944a4f8486a153024d9965aafbe24f5723c1d5c02f4964c045a16d19dc54

ARG VERSION=1.2.[0-9]+
ARG PYTHON_VERSION=3

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
        --with-libiconv \
        ${PYTHON_VERSION:+--enable-python-binding --with-boost-python="$(ls -1 /usr/lib/libboost_python${PYTHON_VERSION}*.so* | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" PYTHON="$(which python${PYTHON_VERSION})"} && \
    make -j$(nproc) && \
    make install-strip && \
    # Test Python binding (before Python is uninstalled)
    if [[ "${PYTHON_VERSION}" != "" ]]; then python${PYTHON_VERSION} -c 'import libtorrent' || exit 1; fi && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
