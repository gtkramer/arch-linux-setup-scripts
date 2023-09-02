#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

# Configure themes and fonts for GTK+ applications independent from GNOME desktop
sudo cp -f "${SCRIPT_DIR}/settings.ini" /etc/gtk-3.0

# Configure themes and fonts for GNOME desktop
gsettings set org.gnome.desktop.interface cursor-size 16
gsettings set org.gnome.desktop.interface cursor-theme 'Breeze'
gsettings set org.gnome.desktop.interface gtk-theme 'Breeze'

gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Sans Bold 10'
gsettings set org.gnome.desktop.interface font-name 'Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Serif 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 11'
