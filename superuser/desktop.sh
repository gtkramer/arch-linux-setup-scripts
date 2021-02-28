#!/bin/bash
# Video capabilities
pacman -Sy --noconfirm xorg-server mesa

# Input capabilities
pacman -Sy --noconfirm xf86-input-libinput

# Audio capabilities
pacman -Sy --noconfirm pulseaudio pulseaudio-alsa

# Desktop environment
pacman -Sy --noconfirm gnome

# Display manager
pacman -Sy --noconfirm gdm
systemctl enable gdm
