#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

## PRIMARY PACKAGES
# Development
pacman_install cmake meson clang lldb dotnet-sdk

# Graphics
pacman_install hugin dcraw
aurman_install pinta

# Hardware
pacman_install solaar

# Multimedia
pacman_install handbrake handbrake-cli mediainfo-gui yt-dlp ffmpegthumbnailer
pacman_install gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire

# Network
pacman_install gnome-browser-connector signal-desktop discord proton-vpn-gtk-app
aurman_install brave-bin
pacman_remove_all epiphany

# Office
pacman_install libreoffice-fresh

# System
pacman_install gptfdisk dosfstools e2fsprogs exfatprogs ntfs-3g hdparm nvme-cli mission-center gparted
pacman_remove_all gnome-system-monitor gnome-disk-utility

# Utilities
pacman_install p7zip man-db dmidecode rsync

## CUSTOM PACKAGES
packages=(vim git visual-studio-code tresorit)
for package in "${packages[@]}"; do
    package_path="${SCRIPT_DIR}/${package}.sh"
    if [[ ! -e "${package_path}" ]]; then
        package_path="${SCRIPT_DIR}/${package}/install.sh"
    fi
    "${package_path}"
done
