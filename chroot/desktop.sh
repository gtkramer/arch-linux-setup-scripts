#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

# Video capabilities
pacman_install xorg-server xorg-xeyes nvidia-open-lts nvidia-utils vulkan-tools

# Audio capabilities
pacman_install pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber

# Desktop environment
pacman_install gnome gnome-tweaks gnome-firmware
pacman_remove_all gnome-software

# Display manager
pacman_install gdm
systemctl enable gdm
