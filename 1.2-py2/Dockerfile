# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.11.6@sha256:39eda93d15866957feaee28f8fc5adb545276a64147445c64992ef69804dbf01

ARG VERSION=1.2.[0-9]\\+

COPY 5026.patch /

SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018,SC2086,SC2169
RUN apk --update add --no-cache                              boost-python2 boost-python3 boost-system libgcc libstdc++ openssl python2 python3 && \
    apk --update add --no-cache --virtual build-dependencies boost-build boost-dev cmake coreutils g++ gcc git py3-setuptools python2-dev python3-dev openssl-dev samurai && \
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
    # Run b2
    PREFIX=/usr && \
    BUILD_CONFIG="release cxxstd=14 crypto=openssl warnings=off address-model=32 -j$(nproc)" && \
    BOOST_ROOT="" b2 ${BUILD_CONFIG} link=shared install --prefix=${PREFIX} && \
    ln -s /usr/lib/libtorrent-rasterbar.so.* /usr/lib/libtorrent-rasterbar.so && \
    BOOST_ROOT="" b2 ${BUILD_CONFIG} link=static install --prefix=${PREFIX} && \
    ln -s /usr/lib/libtorrent.a /usr/lib/libtorrent-rasterbar.a && \
    cd bindings/python && \
    for PYTHON_VERSION in $(seq 2 3); do \
        (PYTHON_MAJOR_MINOR="$(python${PYTHON_VERSION} --version 2>&1 | sed 's/\(python \)\?\([0-9]\+\.[0-9]\+\)\(\.[0-9]\+\)\?/\2/i')" && \
        echo "using python : ${PYTHON_MAJOR_MINOR} : $(command -v python${PYTHON_VERSION}) : /usr/include/python${PYTHON_MAJOR_MINOR} : /usr/lib/python${PYTHON_MAJOR_MINOR} ;" > ~/user-config.jam && \
        ln -s /usr/lib/libboost_python${PYTHON_MAJOR_MINOR/./}.so /usr/lib/libboost_python-py${PYTHON_MAJOR_MINOR/./}.so && \
        BOOST_ROOT="" b2 ${BUILD_CONFIG} install_module python-install-scope=system) || exit 1; \
    done && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*
