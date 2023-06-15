# Instructions on building libtorrent:
#   https://github.com/arvidn/libtorrent/blob/RC_1_2/docs/building.rst

FROM alpine:3.18.2@sha256:5246eec74dffc9a5f6608c4e7c81bd33455ecc64f558bf49eb334c4f05e47eee

ARG VERSION=1.2.[0-9]\\+

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
    # Run b2
    PREFIX=/usr && \
    export BOOST_BUILD_PATH=$(dirname $(find ${PREFIX} -type f -name bootstrap.jam | head -1)) && \
    export BOOST_ROOT="" && \
    BUILD_CONFIG="release cxxstd=14 crypto=openssl warnings=off address-model=32 -j$(nproc)" && \
    b2 ${BUILD_CONFIG} link=shared install --prefix=${PREFIX} && \
    b2 ${BUILD_CONFIG} link=static install --prefix=${PREFIX} && \
    cd bindings/python && \
    PYTHON_MAJOR_MINOR="$(python3 --version 2>&1 | sed 's/\(python \)\?\([0-9]\+\.[0-9]\+\)\(\.[0-9]\+\)\?/\2/i')" && \
    echo "using python : ${PYTHON_MAJOR_MINOR} : $(command -v python3) : /usr/include/python${PYTHON_MAJOR_MINOR} : /usr/lib/python${PYTHON_MAJOR_MINOR} ;" > ~/user-config.jam && \
    b2 ${BUILD_CONFIG} install_module python-install-scope=system && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
