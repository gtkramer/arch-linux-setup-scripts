#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_INSTALL} sddm weston
systemctl enable sddm

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/wayland.conf <<EOF
[General]
DisplayServer=wayland
EOF
