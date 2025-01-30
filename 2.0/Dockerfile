# Instructions on building libtorrent:
#   https://github.com/arvidn/libtorrent/blob/RC_2_0/docs/building.rst

FROM alpine:3.21.2@sha256:56fa17d2a7e7f168a043a2712e63aed1f8543aeafdcee47c58dcffe38ed51099

ARG VERSION=2.0.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018,SC2086
RUN apk --update add --no-cache                              boost-python3 boost-system libgcc libstdc++ openssl python3 && \
    apk --update add --no-cache --virtual build-dependencies boost-build boost-dev cmake coreutils g++ gcc git jq py3-setuptools python3-dev openssl-dev samurai && \
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
    # Build shared libraries
    mkdir build-shared && \
    cd build-shared && \
    cmake \
        -DCMAKE_INSTALL_PREFIX=/usr \
        # https://github.com/arvidn/libtorrent/blob/RC_2_0/docs/building.rst#building-with-cmake
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_STANDARD=17 \
		-Dpython-bindings=ON \
		-Dpython-egg-info=ON \
        .. && \
    ninja "-j$(nproc)" && \
    ninja install && \
    cd .. && \
    # Build static libraries
    mkdir build-static && \
    cd build-static && \
    cmake \
        -DCMAKE_INSTALL_PREFIX=/usr \
        # https://github.com/arvidn/libtorrent/blob/RC_2_0/docs/building.rst#building-with-cmake
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_STANDARD=17 \
		-DBUILD_SHARED_LIBS=OFF \
        .. && \
    ninja "-j$(nproc)" && \
    ninja install && \
    cd .. && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
