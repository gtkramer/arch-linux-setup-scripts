#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../../parameters.sh"

# Install MakeMKV
${AURMAN_INSTALL} makemkv makemkv-libaacs
echo "sg" | sudo tee /etc/modules-load.d/makemkv.conf

# DVD playback
sudo ${PACMAN_INSTALL} libdvdread libdvdcss libdvdnav

# Blu-ray playback
sudo ${PACMAN_INSTALL} libbluray
mkdir -p "${HOME}/.config/aacs"
cp -f "${HOME}/Documents/MakeMKV/KEYDB.cfg" "${HOME}/.config/aacs"
