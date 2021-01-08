# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.12.3@sha256:074d3636ebda6dd446d0d00304c4454f468237fdacf08fb0eeac90bdbfa1bac7

ARG VERSION=1.2.[0-9]\\+

COPY 5026.patch /

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018,SC2169
RUN apk --update add --no-cache                              boost-python3 boost-system libgcc libstdc++ openssl python3 && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev python3-dev && \
    # Checkout from source
    cd "$(mktemp -d)" && \
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout "$( \ 
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
    )" && \
    git clean --force && \
    git submodule update --depth=1 --init --recursive && \
    git apply /5026.patch && rm /5026.patch && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    ./configure \
        --prefix=/usr \
        --with-libiconv \
        --enable-python-binding \
        --with-boost-python="$(find /usr/lib -maxdepth 1 -name "libboost_python3*.so*" | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
        --with-cxx-standard=14 \
        PYTHON="$(which python3)" && \
    make "-j$(nproc)" && \
    make install-strip && \
    apk del --purge python-dependencies && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
