#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
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
