#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

sudo pacman -Sy --noconfirm otf-cascadia-code
aurman -Syu --noconfirm --noedit ttf-ms-fonts
sudo find "$HOME/Documents/Fonts/TTF" -iname '*.ttf' -exec cp {} /usr/share/fonts/TTF/ \;

sudo cp -f "$SCRIPT_DIR/99-generic-family.conf" "$SCRIPT_DIR/98-gnome.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/99-generic-family.conf /etc/fonts/conf.d
sudo ln -sf /usr/share/fontconfig/conf.avail/98-gnome.conf /etc/fonts/conf.d
