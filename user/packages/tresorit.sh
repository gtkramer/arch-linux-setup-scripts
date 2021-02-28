#!/bin/bash
# Uninstall
killall tresorit
killall tresorit-daemon
rm -rf "$HOME"/.local/share/tresorit
# Install
TEMP_DIR="$(mktemp -d)"
pushd "$TEMP_DIR"
curl -LO https://installerstorage.blob.core.windows.net/public/install/tresorit_installer.run
sh ./tresorit_installer.run
popd
rm -rf "$TEMP_DIR"
