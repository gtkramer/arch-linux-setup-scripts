#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo ${PACMAN_INSTALL} git pkgfile
gpg --recv-keys 910B8C499BED531B
manual_aur_install https://aur.archlinux.org/aurman.git

sudo ${PACMAN_INSTALL} reflector
sudo mkdir -p /etc/xdg/reflector
sudo tee /etc/xdg/reflector/reflector.conf <<EOF
--save /etc/pacman.d/mirrorlist
--country "${COUNTRY_MIRROR}"
--protocol https
--sort rate
EOF
sudo systemctl enable --now reflector.timer

sudo sed -i '/^MAKEFLAGS/d' /etc/makepkg.conf
echo "MAKEFLAGS=\"-j$(nproc)\"" | sudo tee -a /etc/makepkg.conf > /dev/null
