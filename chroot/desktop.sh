#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

# Video capabilities
${PACMAN_INSTALL} nvidia nvidia-utils xdg-desktop-portal xdg-desktop-portal-gnome

# Audio capabilities
${PACMAN_INSTALL} pipewire pipewire-alsa pipewire-pulse pipewire-jack

# Desktop environment
${PACMAN_INSTALL} gnome

# Display manager
${PACMAN_INSTALL} gdm
systemctl enable gdm
