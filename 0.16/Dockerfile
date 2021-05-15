# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.7.3@sha256:8421d9a84432575381bfabd248f1eb56f3aa21d9d7cd2511583c68c9b7511d10

ARG VERSION=0.16.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018
RUN apk --update add --no-cache                              boost-system libgcc libstdc++ openssl && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git jq libtool make openssl-dev && \
    # Checkout from source
    cd "$(mktemp -d)" && \
    git clone --branch "$( \ 
        wget -qO - https://api.github.com/repos/arvidn/libtorrent/tags?per_page=100 | jq -r '.[].name' | \
        awk '{print $1" "$1}' | \
        # Get rid of prefixes
        sed 's/^libtorrent[^0-9]//i' | \
        sed 's/^v//i' | \
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
    )" --depth 1 https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git clean --force && \
    git submodule update --depth=1 --init --recursive && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    ./configure \
        CXXFLAGS="-Wno-cpp -Wno-deprecated-declarations -Wno-invalid-offsetof" \
        --prefix=/usr \
        --disable-geoip \
        --with-libiconv && \
    make "-j$(nproc)" && \
    make install-strip && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
