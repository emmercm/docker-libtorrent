#!/usr/bin/env sh
set -euxo pipefail


LIBTORRENT_SO=$(find /usr/local/lib -name libtorrent-rasterbar.so*)

if [[ "${LIBTORRENT_SO}" == "" ]]; then
    echo "Failed to find /usr/local/lib/libtorrent-rasterbar.so*" >&2
    exit 1
fi

echo "Found libtorrent:"
echo "${LIBTORRENT_SO}"


SHARED_SO=$($(for FILE in "${LIBTORRENT_SO}"; do ldd "${FILE}" | awk '{print $3}' | grep -v "^ldd$"; done) | uniq -u)

for SO in "${SHARED_SO}"; do
    if [[ ! -e "${SO}" ]] ; then
        echo "Missing library file: ${LIB}" >&2
        exit 1
    fi
done

echo "Found required libraries:"
echo "${SHARED_SO}"


exit 0
