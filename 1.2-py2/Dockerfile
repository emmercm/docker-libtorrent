# Instructions on building libtorrent:
#   https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#libtorrent
#   https://discourse.osmc.tv/t/howto-update-compile-qbittorrent-nox/19726/3
#   https://git.alpinelinux.org/aports/tree/testing/libtorrent-rasterbar/APKBUILD

FROM alpine:3.11.13@sha256:bcae378eacedab83da66079d9366c8f5df542d7ed9ab23bf487e3e1a8481375d AS build

# Maximum v1.2.12
ARG VERSION=1.2.\\(1[01]\\|[0-9]\\)[^0-9]

COPY 5026.patch /

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
    git submodule update --depth=1 --init --recursive && \
    git apply /5026.patch && rm /5026.patch

# Run autoconf/automake, configure, and make
# hadolint ignore=DL3003,DL3018,SC3060
RUN cd libtorrent && \
    ./autotool.sh && \
    for PYTHON_VERSION in $(seq 2 3); do \
        (apk --update add --no-cache                               "python${PYTHON_VERSION}" "boost-python${PYTHON_VERSION}" && \
        apk add --no-cache "python${PYTHON_VERSION}-dev" && \
        ./configure \
            --prefix=/usr \
            --with-libiconv \
            --enable-python-binding \
            --with-boost-python="$(find /usr/lib -maxdepth 1 -name "libboost_python${PYTHON_VERSION/2/}*.so*" | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
            --with-cxx-standard=14 \
            PYTHON="$(which "python${PYTHON_VERSION}")" && \
        make "-j$(nproc)" && \
        make install-strip DESTDIR=/staging) || exit 1; \
    done

FROM alpine:3.11.13@sha256:bcae378eacedab83da66079d9366c8f5df542d7ed9ab23bf487e3e1a8481375d

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk add --no-cache boost-python2 boost-python3 libcrypto1.1 libgcc libssl1.1 libstdc++ python2 python3
COPY --from=build /staging/usr /usr
