#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

## PRIMARY PACKAGES
# Development
sudo ${PACMAN_INSTALL} cmake meson clang lldb dotnet-sdk

# Graphics
sudo ${PACMAN_INSTALL} hugin dcraw
${AURMAN_INSTALL} pinta

# Hardware
sudo ${PACMAN_INSTALL} solaar

# Multimedia
sudo ${PACMAN_INSTALL} handbrake handbrake-cli mediainfo-gui yt-dlp ffmpegthumbnailer
sudo ${PACMAN_INSTALL} gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire gstreamer-vaapi vpl-gpu-rt libva-utils

# Network
sudo ${PACMAN_INSTALL} gnome-browser-connector signal-desktop discord proton-vpn-gtk-app
${AURMAN_INSTALL} brave-bin
sudo ${PACMAN_REMOVE_ALL} epiphany

# Office
sudo ${PACMAN_INSTALL} libreoffice-fresh

# System
sudo ${PACMAN_INSTALL} gptfdisk dosfstools e2fsprogs exfatprogs ntfs-3g hdparm nvme-cli smartmontools mission-center gparted
sudo ${PACMAN_REMOVE_ALL} gnome-system-monitor gnome-disk-utility

# Utilities
sudo ${PACMAN_INSTALL} p7zip man-db dmidecode rsync

## CUSTOM PACKAGES
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PACKAGES=(vim git visual-studio-code tresorit)
for PACKAGE in "${PACKAGES[@]}"; do
    PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}.sh"
    if [ ! -e "${PACKAGE_PATH}" ]; then
        PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}/install.sh"
    fi
    "${PACKAGE_PATH}"
done
