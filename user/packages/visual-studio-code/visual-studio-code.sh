#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
aurman -Sy --noconfirm --noedit visual-studio-code-bin
sudo cp -f "$SCRIPT_DIR/98-visual-studio-code.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/98-visual-studio-code.conf /etc/fonts/conf.d
