#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_INSTALL} weston

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/hidpi.conf <<EOF
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell,QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192
EOF
