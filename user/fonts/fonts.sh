#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

sudo pacman -Sy --noconfirm $(sudo pacman -Ssq adobe-source-.*-fonts)
aurman -Syu ttf-ms-fonts

sudo cp -f "$SCRIPT_DIR/99-generic-family.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/99-generic-family.conf /etc/fonts/conf.d
