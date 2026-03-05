#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../common.sh"

pacman_install git pkgfile
manual_aur_install https://aur.archlinux.org/yay.git

pacman_install reflector
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
