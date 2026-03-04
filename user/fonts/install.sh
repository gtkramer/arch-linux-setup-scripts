#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

local_packages=(otf-noto-fonts otf-noto-fonts-cjk)
for local_package in "${local_packages[@]}"; do
    pushd "${SCRIPT_DIR}/${local_package}"
    makepkg --noconfirm -sri
    popd
done

pacman_install noto-fonts-{emoji,extra} otf-cascadia-code
aurman_install ttf-ms-fonts

sudo cp -f "${SCRIPT_DIR}/99-generic-family.conf" "${SCRIPT_DIR}/98-gnome.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/99-generic-family.conf /etc/fonts/conf.d
sudo ln -sf /usr/share/fontconfig/conf.avail/98-gnome.conf /etc/fonts/conf.d
