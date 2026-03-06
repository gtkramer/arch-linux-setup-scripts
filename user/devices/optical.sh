#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../../common.sh"

# Install MakeMKV
aur_install makemkv makemkv-libaacs
echo "sg" | sudo tee /etc/modules-load.d/makemkv.conf

# DVD playback
pacman_install libdvdread libdvdcss libdvdnav

# Blu-ray playback
pacman_install libbluray
mkdir -p "${HOME}/.config/aacs"
cp -f "${HOME}/Documents/MakeMKV/KEYDB.cfg" "${HOME}/.config/aacs"
