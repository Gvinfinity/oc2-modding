#!/usr/bin/env bash

set -euo pipefail

TOOLS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${TOOLS_DIR}/.."
DIST_DIR="${ROOT_DIR}/dist"
TMP_DIR="${TMPDIR:-/tmp}/oc2-modding-deps"

command -v curl >/dev/null 2>&1 || {
    printf 'Error: curl is required but was not found in PATH.\n' >&2
    exit 1
}
command -v unzip >/dev/null 2>&1 || {
    printf 'Error: unzip is required but was not found in PATH.\n' >&2
    exit 1
}

mkdir -p "${DIST_DIR}" "${TMP_DIR}"

fetch_and_extract() {
    local url="$1"
    local archive_name="$2"
    local extract_dir="${DIST_DIR}/$3"
    local archive_path="${TMP_DIR}/${archive_name}"

    if [[ -e "${extract_dir}" ]]; then
        return 0
    fi

    printf 'Fetch %s...\n' "${archive_name}"
    curl --fail --location --retry 3 --output "${archive_path}" "${url}"
    rm -rf "${extract_dir}"
    mkdir -p "${extract_dir}"
    unzip -q "${archive_path}" -d "${extract_dir}"
    rm -f "${archive_path}"
}

fetch_and_extract \
    'https://github.com/BepInEx/BepInEx/releases/download/v5.4.21/BepInEx_x86_5.4.21.0.zip' \
    'BepInEx_x86_5.4.21.0.zip' \
    'BepInEx_x86_5.4.21.0'

fetch_and_extract \
    'https://github.com/BepInEx/BepInEx/releases/download/v6.0.0-pre.1/BepInEx_UnityMono_x64_6.0.0-pre.1.zip' \
    'BepInEx_UnityMono_x64_6.0.0-pre.1.zip' \
    'BepInEx_UnityMono_x64_6.0.0-pre.1'

fetch_and_extract \
    'https://curl.se/windows/dl-8.19.0_4/curl-8.19.0_4-win64-mingw.zip' \
    'curl-8.19.0_4-win64-mingw.zip' \
    'curl'

if [[ -d "${DIST_DIR}/curl/curl-8.19.0_4-win64-mingw" ]]; then
    find "${DIST_DIR}/curl/curl-8.19.0_4-win64-mingw" -mindepth 1 -maxdepth 1 \
        ! -name bin -exec rm -rf {} +
    if [[ -d "${DIST_DIR}/curl/curl-8.19.0_4-win64-mingw/bin" ]]; then
        cp -a "${DIST_DIR}/curl/curl-8.19.0_4-win64-mingw/bin/." \
            "${DIST_DIR}/curl/curl-8.19.0_4-win64-mingw/"
        rm -rf "${DIST_DIR}/curl/curl-8.19.0_4-win64-mingw/bin"
    fi
    mv "${DIST_DIR}/curl/curl-8.19.0_4-win64-mingw" "${DIST_DIR}/curl/curl"
fi
