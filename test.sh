#!/usr/bin/env sh
set -euo pipefail


# Ensure libtorrent-rasterbar.a* exists
LIBTORRENT_A=$(find /usr/lib -type f -name libtorrent-rasterbar.a* | sort)
if [[ "${LIBTORRENT_A}" == "" ]]; then
    echo "Failed to find /usr/lib/libtorrent-rasterbar.a*" >&2
    exit 1
fi
echo "Found libtorrent static libraries:"
echo "${LIBTORRENT_A}"


# Ensure libtorrent-rasterbar.so* exists
LIBTORRENT_SO=$(find /usr/lib -type f -name libtorrent-rasterbar.so* | sort)
if [[ "${LIBTORRENT_SO}" == "" ]]; then
    echo "Failed to find /usr/lib/libtorrent-rasterbar.so*" >&2
    exit 1
fi
echo "Found libtorrent shared objects:"
echo "${LIBTORRENT_SO}"

# Ensure libtorrent-rasterbar.so dependencies exist
SHARED_SO=$(ldd /usr/lib/libtorrent-rasterbar.so* | awk '{print $3}' | sed '/^$/d' | sed '/^ldd$/d' | sort)
for SO in ${SHARED_SO}; do
    if [[ ! -e "${SO}" ]] ; then
        echo "Missing library file: ${LIB}" >&2
        exit 1
    fi
done
echo "Found libraries required by libtorrent shared objects:"
echo "${SHARED_SO}"


# Ensure libtorrent.cpython-*.so dependencies exist
if [[ "${PYTHON_VERSION:-}" != "" ]]; then
    PYTHON_SO=$(ldd /usr/lib/python*/site-packages/libtorrent.cpython-*.so | awk '{print $3}' | sed '/^$/d' | sed '/^ldd$/d' | sort)
    for SO in ${PYTHON_SO}; do
        if [[ ! -e "${SO}" ]] ; then
            echo "Missing library file: ${LIB}" >&2
            exit 1
        fi
    done
    echo "Found libraries required by libtorrent Python binding shared objects:"
    echo "${PYTHON_SO}"
fi


exit 0
