#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

# Uninstall
killall tresorit || true
killall tresorit-daemon || true
sudo ${PACMAN_INSTALL} fuse2 libglvnd libx11 libxcb libxext libxkbcommon libxkbcommon-x11 xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm
rm -rf "${HOME}/.local/share/tresorit"

# Install
TEMP_DIR="$(mktemp -d)"
pushd "${TEMP_DIR}"
curl -LO https://installerstorage.blob.core.windows.net/public/install/tresorit_installer.run
sh ./tresorit_installer.run
popd
rm -rf "${TEMP_DIR}"
