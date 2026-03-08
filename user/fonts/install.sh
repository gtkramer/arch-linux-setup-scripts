#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../../common.sh"

pacman_install otf-noto-fonts otf-noto-fonts-{extra,cjk,emoji} otf-cascadia-code
aur_install ttf-ms-fonts

sudo cp -f "${SCRIPT_DIR}/99-generic-family.conf" "${SCRIPT_DIR}/98-gnome.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/99-generic-family.conf /etc/fonts/conf.d
sudo ln -sf /usr/share/fontconfig/conf.avail/98-gnome.conf /etc/fonts/conf.d
