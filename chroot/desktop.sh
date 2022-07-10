#!/bin/bash
# Video capabilities
pacman -Sy --noconfirm nvidia nvidia-utils xdg-desktop-portal xdg-desktop-portal-gnome

# Audio capabilities
pacman -Sy --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack

# Desktop environment
pacman -Sy --noconfirm gnome

# Display manager
pacman -Sy --noconfirm gdm
systemctl enable gdm
