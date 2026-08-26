#!/usr/bin/env bash

set -euo pipefail

DIST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NO_PAUSE=""
GAME_PATH=""

if [[ "${1:-}" == "nopause" ]]; then
    NO_PAUSE="nopause"
    GAME_PATH="${2:-}"
else
    GAME_PATH="${1:-}"
fi

fail() {
    printf 'Error: %s\n' "$1" >&2
    if [[ "${NO_PAUSE}" != "nopause" && -t 0 ]]; then
        read -r -p 'Press Enter to exit...' || true
    fi
    exit 1
}

printf '\nOvercooked! 2 Mod Installer\n\n'

required_paths=(
    "${DIST_DIR}/com.github.toasterparty.oc2modding.steam.dll"
    "${DIST_DIR}/com.github.toasterparty.oc2modding.epic.dll"
    "${DIST_DIR}/leaderboard_scores.csv"
    "${DIST_DIR}/curl/curl/curl.exe"
    "${DIST_DIR}/BepInEx_x86_5.4.21.0"
    "${DIST_DIR}/BepInEx_UnityMono_x64_6.0.0-pre.1"
    "${DIST_DIR}/c-wspp-websocket-v0.4.1/win32"
    "${DIST_DIR}/c-wspp-websocket-v0.4.1/win64"
)

for required_path in "${required_paths[@]}"; do
    [[ -e "${required_path}" ]] || fail "Corrupt installation package. If you are a developer, please refer to the README."
done

if [[ -z "${GAME_PATH}" ]]; then
    printf 'Enter the path to your Overcooked! 2 executable: '
    read -r GAME_PATH || fail 'No game executable was provided.'
fi

[[ -e "${GAME_PATH}" ]] || fail "Game executable not found: ${GAME_PATH}"

if [[ -d "${GAME_PATH}" ]]; then
    GAME_DIR="$(cd -- "${GAME_PATH}" && pwd)"
else
    GAME_DIR="$(cd -- "$(dirname -- "${GAME_PATH}")" && pwd)"
fi

BEPINEX_DIR="${GAME_DIR}/BepInEx"
PLUGINS_DIR="${BEPINEX_DIR}/plugins"
mkdir -p "${PLUGINS_DIR}"

printf "Installing 'OC2 Modding' into %s...\n\n" "${PLUGINS_DIR}"


shopt -s nullglob
plugin_dlls=("${DIST_DIR}"/*.dll)
if ((${#plugin_dlls[@]})); then
    cp -f "${plugin_dlls[@]}" "${PLUGINS_DIR}/"
fi
shopt -u nullglob

if [[ -e "${GAME_DIR}/UnityCrashHandler64.exe" ]]; then
    cp -a "${DIST_DIR}/BepInEx_UnityMono_x64_6.0.0-pre.1/." "${GAME_DIR}/"
    cp -a "${DIST_DIR}/c-wspp-websocket-v0.4.1/win64/." "${PLUGINS_DIR}/"
    rm -f "${PLUGINS_DIR}/com.github.toasterparty.oc2modding.steam.dll"
else
    cp -a "${DIST_DIR}/BepInEx_x86_5.4.21.0/." "${GAME_DIR}/"
    cp -a "${DIST_DIR}/c-wspp-websocket-v0.4.1/win32/." "${PLUGINS_DIR}/"
    rm -f "${PLUGINS_DIR}/com.github.toasterparty.oc2modding.epic.dll"
    cp -f "${DIST_DIR}/steam_doorstop_config.ini" "${GAME_DIR}/doorstop_config.ini" 2>/dev/null || true
fi

cp -f "${DIST_DIR}/leaderboard_scores.csv" "${GAME_DIR}/"
cp -a "${DIST_DIR}/curl" "${GAME_DIR}/"

printf '\nSuccessfully installed '\''OC2 Modding'\''\n'
printf '(You may now close this window)\n\n'

if [[ "${NO_PAUSE}" != "nopause" && -t 0 ]]; then
    read -r -p 'Press Enter to exit...' || true
fi
