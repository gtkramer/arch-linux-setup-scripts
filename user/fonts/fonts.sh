#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

sudo pacman -Sy --noconfirm $(sudo pacman -Ssq adobe-source-.*-fonts)
aurman -Sy ttf-ms-win10

sudo cp -f "$SCRIPT_DIR/99-generic-family.conf" /etc/fonts/conf.avail
sudo ln -sf /etc/fonts/conf.avail/99-generic-family.conf /etc/fonts/conf.d
