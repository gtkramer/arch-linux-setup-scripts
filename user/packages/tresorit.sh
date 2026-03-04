#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../common.sh"

# Uninstall
killall tresorit || true
killall tresorit-daemon || true
pacman_install fuse2 libglvnd libx11 libxcb libxext libxkbcommon libxkbcommon-x11 xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm
rm -rf "${HOME}/.local/share/tresorit"

# Install
temp_dir="$(mktemp -d)"
pushd "${temp_dir}"
curl -LO https://installerstorage.blob.core.windows.net/public/install/tresorit_installer.run
sh ./tresorit_installer.run
popd
rm -rf "${temp_dir}"
