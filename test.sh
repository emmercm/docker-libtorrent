#!/usr/bin/env sh
set -euo pipefail

if [[ "$(find /usr/local/lib -name libtorrent-rasterbar.so*)" == "" ]]; then
    echo "Failed to find /usr/local/lib/libtorrent-rasterbar.so*" >&2
    exit 1
fi

for FILE in $(find /usr/local/lib -name libtorrent-rasterbar.so*); do
    for LIB in $(ldd "${FILE}" | awk '{print $3}' | grep -v "^ldd$"); do
        if [[ ! -e "${LIB}" ]]; then
            echo "Missing library: ${LIB}" >&2
            exit 1
        fi 
    done 
done

exit 0
