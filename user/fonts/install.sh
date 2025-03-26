#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

LOCAL_PACKAGES=(otf-noto-fonts otf-noto-fonts-cjk)
for LOCAK_PACKAGE in "${LOCAL_PACKAGES[@]}"; do
    pushd "${SCRIPT_DIR}/${LOCAL_PACKAGE}"
    makepkg --noconfirm -sri
    popd
done

sudo ${PACMAN_INSTALL} noto-fonts-{emoji,extra} otf-cascadia-code
${AURMAN_INSTALL} ttf-ms-fonts

sudo cp -f "${SCRIPT_DIR}/99-generic-family.conf" "${SCRIPT_DIR}/98-gnome.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/99-generic-family.conf /etc/fonts/conf.d
sudo ln -sf /usr/share/fontconfig/conf.avail/98-gnome.conf /etc/fonts/conf.d
