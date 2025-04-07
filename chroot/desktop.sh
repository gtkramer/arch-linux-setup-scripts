#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

# Video capabilities
${PACMAN_INSTALL} xorg-server xorg-xeyes mesa mesa-utils vulkan-intel vulkan-tools intel-gpu-tools
cat >> /etc/modprobe.d/intel-xe.conf <<EOF
options i915 force_probe=!56a0
options xe force_probe=56a0
EOF

# Audio capabilities
${PACMAN_INSTALL} pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber

# Desktop environment
${PACMAN_INSTALL} gnome gnome-tweaks gnome-firmware
${PACMAN_REMOVE_ALL} gnome-software

# Display manager
${PACMAN_INSTALL} gdm
systemctl enable gdm
