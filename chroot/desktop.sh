#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

# Video capabilities
${PACMAN_INSTALL} nvidia nvidia-utils
systemctl enable nvidia-{hibernate,suspend,resume}
cat >> /etc/modprobe.d/nvidia.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia-drm modeset=1
EOF
mkinitcpio -p linux

# Audio capabilities
${PACMAN_INSTALL} pipewire pipewire-alsa pipewire-pulse pipewire-jack
${PACMAN_INSTALL} xdg-desktop-portal xdg-desktop-portal-gnome

# Desktop environment
${PACMAN_INSTALL} gnome

# Display manager
${PACMAN_INSTALL} gdm
systemctl enable gdm
