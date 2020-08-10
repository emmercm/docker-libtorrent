# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.7.3@sha256:92251458088c638061cda8fd8b403b76d661a4dc6b7ee71b6affcf1872557b2b

ARG VERSION=1.0.[0-9]+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018,SC2169
RUN apk --update add --no-cache                              boost-system libgcc libstdc++ openssl && \
    apk --update add --no-cache --virtual build-dependencies autoconf automake boost-dev coreutils file g++ gcc git libtool make openssl-dev && \
    # Checkout from source
    cd "$(mktemp -d)" && \
    git clone https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git checkout "$(git tag --sort=-version:refname | grep "${VERSION}" | head -1)" && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    for PYTHON_VERSION in $(seq 2 3); do \
        (apk --update add --no-cache                               "boost-python${PYTHON_VERSION/2/}" && \
        apk --update add --no-cache --virtual python-dependencies "python${PYTHON_VERSION}-dev" && \
        ./configure \
            CXXFLAGS="-Wno-cpp -Wno-deprecated-declarations -Wno-invalid-offsetof" \
            --prefix=/usr \
            --disable-geoip \
            --with-libiconv \
            --enable-python-binding \
            --with-boost-python="$(find /usr/lib -maxdepth 1 -name "libboost_python${PYTHON_VERSION/2/}*.so*" | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
            PYTHON="$(which "python${PYTHON_VERSION}")" && \
        make "-j$(nproc)" && \
        make install-strip && \
        apk del --purge python-dependencies) || exit 1; \
    done && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
