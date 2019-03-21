#!/usr/bin/env sh
set -euxo pipefail


# Ensure libtorrent-rasterbar.so exists
LIBTORRENT_SO=$(find /usr/local/lib -name libtorrent-rasterbar.so*)
if [[ "${LIBTORRENT_SO}" == "" ]]; then
    echo "Failed to find /usr/local/lib/libtorrent-rasterbar.so*" >&2
    exit 1
fi
echo "Found libtorrent:"
echo "${LIBTORRENT_SO}"

# Ensure libtorrent-rasterbar.so dependencies exist
echo 1
ldd /usr/local/lib/libtorrent-rasterbar.so*
echo 2
ldd /usr/local/lib/libtorrent-rasterbar.so* | sed '/^$/d'
echo 3
ldd /usr/local/lib/libtorrent-rasterbar.so* | sed '/^$/d' | awk '{print $3}'
echo 4
ldd /usr/local/lib/libtorrent-rasterbar.so* | sed '/^$/d' | awk '{print $3}' | sed '/^ldd$/d'
echo 5
ldd /usr/local/lib/libtorrent-rasterbar.so* | sed '/^$/d' | awk '{print $3}' | sed '/^ldd$/d' | sort
SHARED_SO=$(ldd /usr/local/lib/libtorrent-rasterbar.so* | sed '/^$/d' | awk '{print $3}' | sed '/^ldd$/d' | sort)
for SO in ${SHARED_SO}; do
    if [[ ! -e "${SO}" ]] ; then
        echo "Missing library file: ${LIB}" >&2
        exit 1
    fi
done
echo "Found required libraries:"
echo "${SHARED_SO}"

exit 0
