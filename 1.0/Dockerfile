# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.7.3@sha256:8421d9a84432575381bfabd248f1eb56f3aa21d9d7cd2511583c68c9b7511d10 AS build

ARG VERSION=1.0.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk add --no-cache autoconf automake boost-dev coreutils file g++ gcc git jq libtool make openssl-dev

# Checkout from source
# hadolint ignore=DL3003
RUN git clone --branch "$( \
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
        # Ignore pre-releases (release candidates, betas, etc.)
        grep -viE -- '-(rc|alpha|beta)' | \
        tail -1 | \
        awk '{print $2}' \
    )" --depth 1 https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git clean --force && \
    git submodule update --depth=1 --init --recursive

# Run autoconf/automake, configure, and make
# hadolint ignore=DL3003,DL3018,SC3060
RUN cd libtorrent && \
    ./autotool.sh && \
    for PYTHON_VERSION in $(seq 2 3); do \
        (apk add --no-cache "boost-python${PYTHON_VERSION/2/}" && \
        apk add --no-cache "python${PYTHON_VERSION}-dev" && \
        ./configure \
            CXXFLAGS="-Wno-cpp -Wno-deprecated-declarations -Wno-invalid-offsetof" \
            --prefix=/usr \
            --disable-geoip \
            --with-libiconv \
            --enable-python-binding \
            --with-boost-python="$(find /usr/lib -maxdepth 1 -name "libboost_python${PYTHON_VERSION/2/}*.so*" | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
            PYTHON="$(which "python${PYTHON_VERSION}")" && \
        make "-j$(nproc)" && \
        make install-strip DESTDIR=/staging) || exit 1; \
    done

FROM alpine:3.7.3@sha256:8421d9a84432575381bfabd248f1eb56f3aa21d9d7cd2511583c68c9b7511d10

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk add --no-cache boost-python boost-python3 boost-system libcrypto1.0 libgcc libssl1.0 libstdc++ python2 python3 zlib
COPY --from=build /staging/usr /usr
