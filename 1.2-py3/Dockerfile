# Instructions on building libtorrent:
#   https://github.com/arvidn/libtorrent/blob/RC_1_2/docs/building.rst

FROM alpine:3.13.3@sha256:826f70e0ac33e99a72cf20fb0571245a8fee52d68cb26d8bc58e53bfa65dcdfa

ARG VERSION=1.2.[0-9]\\+

COPY *.patch /

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018,SC2086
RUN apk --update add --no-cache                              boost-python3 boost-system libgcc libstdc++ openssl python3 && \
    apk --update add --no-cache --virtual build-dependencies boost-build boost-dev cmake coreutils g++ gcc git py3-setuptools python3-dev openssl-dev samurai && \
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
    git apply /5874.patch && rm /5874.patch && \
    git apply /5894.patch && rm /5894.patch && \
    # Run b2
    PREFIX=/usr && \
    BUILD_CONFIG="release cxxstd=14 crypto=openssl warnings=off address-model=32 -j$(nproc)" && \
    BOOST_ROOT="" b2 ${BUILD_CONFIG} link=shared install --prefix=${PREFIX} && \
    ln -s /usr/lib/libtorrent-rasterbar.so.* /usr/lib/libtorrent-rasterbar.so && \
    BOOST_ROOT="" b2 ${BUILD_CONFIG} link=static install --prefix=${PREFIX} && \
    ln -s /usr/lib/libtorrent.a /usr/lib/libtorrent-rasterbar.a && \
    cd bindings/python && \
    PYTHON_MAJOR_MINOR="$(python3 --version 2>&1 | sed 's/\(python \)\?\([0-9]\+\.[0-9]\+\)\(\.[0-9]\+\)\?/\2/i')" && \
    echo "using python : ${PYTHON_MAJOR_MINOR} : $(command -v python3) : /usr/include/python${PYTHON_MAJOR_MINOR} : /usr/lib/python${PYTHON_MAJOR_MINOR} ;" > ~/user-config.jam && \
    BOOST_ROOT="" b2 ${BUILD_CONFIG} install_module python-install-scope=system && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
