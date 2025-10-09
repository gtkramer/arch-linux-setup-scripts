#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

## PRIMARY USER APPLICATIONS
# Development
sudo ${PACMAN_INSTALL} cmake meson clang lldb dotnet-sdk

# Graphics
sudo ${PACMAN_INSTALL} hugin dcraw pinta

# Hardware
sudo ${PACMAN_INSTALL} solaar

# Multimedia
sudo ${PACMAN_INSTALL} handbrake handbrake-cli mediainfo-gui yt-dlp
sudo ${PACMAN_INSTALL} gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire gstreamer-vaapi vpl-gpu-rt libva-utils

# Network
sudo ${PACMAN_INSTALL} gnome-browser-connector signal-desktop discord proton-vpn-gtk-app
sudo ${PACMAN_REMOVE_ALL} epiphany

# System
sudo ${PACMAN_INSTALL} gptfdisk dosfstools e2fsprogs exfat-utils ntfs-3g hdparm nvme-cli mission-center

# Utilities
sudo ${PACMAN_INSTALL} p7zip man-db dmidecode rsync

## BASE DESKTOP APPLICATIONS
# System
${AURMAN_INSTALL} hardinfo2

## CUSTOM PACKAGES
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PACKAGES=(vim git visual-studio-code edge tresorit)
for PACKAGE in "${PACKAGES[@]}"; do
    PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}.sh"
    if [ ! -e "${PACKAGE_PATH}" ]; then
        PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}/install.sh"
    fi
    "${PACKAGE_PATH}"
done
