# Instructions on building libtorrent:
#   https://github.com/arvidn/libtorrent/blob/libtorrent-2.0-RC2/docs/building.rst

FROM alpine:3.12.1

ARG VERSION=2.0.[0-9]+

# Build libtorrent-rasterbar-dev
RUN set -euo pipefail && \
    # Install both library dependencies and build dependencies
    cd $(mktemp -d) && \
    apk --update add --no-cache                              boost-python3 boost-system libgcc libstdc++ openssl python3 && \
    apk --update add --no-cache --virtual build-dependencies boost-build boost-dev cmake coreutils g++ gcc git python3-dev samurai && \
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
    git submodule update --depth=1 --init --recursive && \
    # Run make
    for DIR in /usr/lib/cmake/boost_python*; do \
        (ln -s "${DIR}/boost_python-config.cmake" "${DIR}/boost_python3-config.cmake" && \
        ln -s "${DIR}/boost_python-config-version.cmake" "${DIR}/boost_python3-config-version.cmake") || exit 1; \
    done && \
    mkdir build && \
    cd build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=14 \
        -Dpython-bindings=ON \
        -Dboost_python3_DIR="$(find /usr/lib/cmake -maxdepth 1 -type d -name 'boost_python*')" \
        -G Ninja .. && \
    ninja -j$(nproc) && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
