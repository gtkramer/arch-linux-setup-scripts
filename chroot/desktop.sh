#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

# Video capabilities
${PACMAN_INSTALL} xorg-server xorg-xwininfo mesa mesa-utils vulkan-intel vulkan-tools intel-media-driver libva-utils

# Audio capabilities
${PACMAN_INSTALL} pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber

# Desktop environment
${PACMAN_INSTALL} plasma-meta plasma-wayland-session konsole dolphin
