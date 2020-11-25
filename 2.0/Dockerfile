# Instructions on building libtorrent:
#   https://github.com/arvidn/libtorrent/blob/RC_2_0/docs/building.rst

FROM alpine:3.12.1

ARG VERSION=2.0.[0-9]+

# Build libtorrent-rasterbar-dev
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-python3 boost-system libgcc libstdc++ openssl python3 && \
    apk --update add --no-cache --virtual build-dependencies boost-build boost-dev cmake coreutils g++ gcc git py3-setuptools python3-dev samurai && \
    # Checkout from source
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
    # Run b2 (config from the Makefile)
    for DIR in /usr/lib/cmake/boost_python*; do \
        (ln -s "${DIR}/boost_python-config.cmake" "${DIR}/boost_python3-config.cmake" && \
        ln -s "${DIR}/boost_python-config-version.cmake" "${DIR}/boost_python3-config-version.cmake") || exit 1; \
    done && \
    PREFIX=/usr && \
    BUILD_CONFIG="release cxxstd=14 warnings=off address-model=32 -j$(nproc)" && \
    BOOST_ROOT="" b2 ${BUILD_CONFIG} link=shared install --prefix=${PREFIX} && \
    BOOST_ROOT="" b2 ${BUILD_CONFIG} link=static install --prefix=${PREFIX} && \
    cd bindings/python && \
    LIBTORRENT_PYTHON_INTERPRETER="$(which python3)" BOOST_ROOT="" b2 ${BUILD_CONFIG} install_module python-install-scope=system&& \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
