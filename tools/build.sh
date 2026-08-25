#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
SRC_DIR="${ROOT_DIR}/OC2Modding"
DIST_DIR="${ROOT_DIR}/dist"
BUILD_DIR="${SRC_DIR}/bin/Debug"

command -v dotnet >/dev/null 2>&1 || {
    printf 'Error: dotnet is required but was not found in PATH.\n' >&2
    exit 1
}
command -v curl >/dev/null 2>&1 || {
    printf 'Error: curl is required but was not found in PATH.\n' >&2
    exit 1
}

mkdir -p "${DIST_DIR}" "${ROOT_DIR}/release"

cp "${SRC_DIR}/OC2Modding.csproj.epic" "${SRC_DIR}/OC2Modding.csproj"
(
    cd "${SRC_DIR}"
    dotnet restore
    dotnet build
)

cp "${SRC_DIR}/OC2Modding.csproj.steam" "${SRC_DIR}/OC2Modding.csproj"
(
    cd "${SRC_DIR}"
    dotnet restore
    dotnet build
)

cp "${BUILD_DIR}/net46/com.github.toasterparty.oc2modding.epic.dll" "${DIST_DIR}/"
cp "${BUILD_DIR}/net35/com.github.toasterparty.oc2modding.steam.dll" "${DIST_DIR}/"
cp "${BUILD_DIR}/net35/Archipelago.MultiClient.Net.dll" "${DIST_DIR}/"
cp "${BUILD_DIR}/net35/Newtonsoft.Json.dll" "${DIST_DIR}/"
curl --fail --location \
    'https://overcooked.greeny.dev/assets/data/data.csv' \
    --output "${DIST_DIR}/leaderboard_scores.csv"

printf '\nSuccessfully built '\''OC2 Modding'\''\n\n'
