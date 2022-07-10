#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

# Uninstall
killall tresorit
killall tresorit-daemon
sudo ${PACMAN_INSTALL} xcb-util-wm xcb-util-image xcb-util-keysyms xcb-util-renderutil
rm -rf "${HOME}"/.local/share/tresorit
# Install
TEMP_DIR="$(mktemp -d)"
pushd "${TEMP_DIR}"
curl -LO https://installerstorage.blob.core.windows.net/public/install/tresorit_installer.run
sh ./tresorit_installer.run
popd
rm -rf "${TEMP_DIR}"
