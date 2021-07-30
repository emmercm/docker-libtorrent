# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.11.11@sha256:6cf3d8abc08cf3792d590152d7a4628ec827621f55b1d3150383f5f39335d6eb

ARG VERSION=1.2.[0-9]+

COPY 5026.patch /

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018,SC2169
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
    git apply /5026.patch && rm /5026.patch && \
    # Run autoconf/automake, configure, and make
    ./autotool.sh && \
    for PYTHON_VERSION in $(seq 2 3); do \
        (apk --update add --no-cache                               "python${PYTHON_VERSION}" "boost-python${PYTHON_VERSION}" && \
        apk --update add --no-cache --virtual python-dependencies "python${PYTHON_VERSION}-dev" && \
        ./configure \
            --prefix=/usr \
            --with-libiconv \
            --enable-python-binding \
            --with-boost-python="$(find /usr/lib -maxdepth 1 -name "libboost_python${PYTHON_VERSION/2/}*.so*" | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
            --with-cxx-standard=14 \
            PYTHON="$(which "python${PYTHON_VERSION}")" && \
        make "-j$(nproc)" && \
        make install-strip && \
        apk del --purge python-dependencies) || exit 1; \
    done && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
