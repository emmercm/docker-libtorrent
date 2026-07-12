# Instructions on building libtorrent:
#   https://github.com/arvidn/libtorrent/blob/RC_2_0/docs/building.rst

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS build

ARG VERSION=2.0.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk add --no-cache boost-dev cmake coreutils g++ gcc git jq py3-setuptools python3-dev openssl-dev samurai

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

# Build shared libraries
# hadolint ignore=DL3003
RUN cd libtorrent && \
    mkdir build-shared && \
    cd build-shared && \
    cmake \
        -DCMAKE_INSTALL_PREFIX=/usr \
        # https://github.com/arvidn/libtorrent/blob/RC_2_0/docs/building.rst#building-with-cmake
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
        -Dpython-bindings=ON \
        -Dpython-egg-info=ON \
        -Dpython-install-system-dir=ON \
        .. && \
    ninja "-j$(nproc)" && \
    DESTDIR=/staging ninja install

# Build static libraries
# hadolint ignore=DL3003
RUN cd libtorrent && \
    mkdir build-static && \
    cd build-static && \
    cmake \
        -DCMAKE_INSTALL_PREFIX=/usr \
        # https://github.com/arvidn/libtorrent/blob/RC_2_0/docs/building.rst#building-with-cmake
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
        -DBUILD_SHARED_LIBS=OFF \
        .. && \
    ninja "-j$(nproc)" && \
    DESTDIR=/staging ninja install

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk add --no-cache boost-python3 libcrypto3 libgcc libssl3 libstdc++ python3
COPY --from=build /staging/usr /usr
