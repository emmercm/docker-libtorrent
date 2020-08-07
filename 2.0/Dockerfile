# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.12.0

ARG VERSION=2.0.[0-9]+

# Build libtorrent-rasterbar-dev
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-python3 boost-system libgcc libstdc++ openssl python3 && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev python3-dev && \
    # Checkout from source
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout $( \ 
        git tag | \
        awk '{print $1" "$1}' | \
        # Get rid of prefix
        sed 's/^libtorrent[^0-9]//i' | \
        # Use periods for major.minor.patch
        sed 's/[^a-zA-Z0-9.]\([0-9]\+.* .*\)/.\1/g' | \
        sed 's/[^a-zA-Z0-9.]\([0-9]\+.* .*\)/.\1/g' | \
        # Make sure patch version exists
        sed 's/^\([0-9]\+\.[0-9]\+\)\([^0-9.].\+\)/\1.0\2/' | \
        # Get the right version
        sort --version-sort --key=1,1 | \
        grep "${VERSION}" | \
        tail -1 | \
        awk '{print $2}' \
    ) && \
    git clean --force && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    ./configure \
        --prefix=/usr \
        --with-libiconv \
        --enable-python-binding && \
    make V=1 -j$(nproc) && \
    make install-strip && \
    git submodule update --depth=1 --init --recursive && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
