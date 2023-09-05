#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} noto-fonts noto-fonts-{cjk,emoji,extra} otf-cascadia-code gnu-free-fonts
${AURMAN_INSTALL} ttf-ms-fonts

sudo cp -f "${SCRIPT_DIR}/99-generic-family.conf" "${SCRIPT_DIR}/98-gnome.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/99-generic-family.conf /etc/fonts/conf.d
sudo ln -sf /usr/share/fontconfig/conf.avail/98-gnome.conf /etc/fonts/conf.d
