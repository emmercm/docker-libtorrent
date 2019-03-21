#!/usr/bin/env sh
set -euo pipefail


# Ensure libtorrent-rasterbar.a* exists
LIBTORRENT_A=$(find /usr/local/lib -name libtorrent-rasterbar.a* | sort)
if [[ "${LIBTORRENT_A}" == "" ]]; then
    echo "Failed to find /usr/local/lib/libtorrent-rasterbar.a*" >&2
    exit 1
fi
echo "Found libtorrent static libraries:"
echo "${LIBTORRENT_A}"


# Ensure libtorrent-rasterbar.so* exists
LIBTORRENT_SO=$(find /usr/local/lib -name libtorrent-rasterbar.so* | sort)
if [[ "${LIBTORRENT_SO}" == "" ]]; then
    echo "Failed to find /usr/local/lib/libtorrent-rasterbar.so*" >&2
    exit 1
fi
echo "Found libtorrent shared objects:"
echo "${LIBTORRENT_SO}"

# Ensure libtorrent-rasterbar.so dependencies exist
SHARED_SO=$(ldd /usr/local/lib/libtorrent-rasterbar.so* | awk '{print $3}' | sed '/^$/d' | sed '/^ldd$/d' | sort)
for SO in ${SHARED_SO}; do
    if [[ ! -e "${SO}" ]] ; then
        echo "Missing library file: ${LIB}" >&2
        exit 1
    fi
done
echo "Found libraries required by shared objects:"
echo "${SHARED_SO}"


exit 0
