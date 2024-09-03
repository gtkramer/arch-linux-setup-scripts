#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

## PRIMARY USER APPLICATIONS
# Development
sudo ${PACMAN_INSTALL} clang lldb dotnet-sdk

# Graphics
sudo ${PACMAN_INSTALL} hugin dcraw pinta

# Multimedia
sudo ${PACMAN_INSTALL} gnome-music celluloid handbrake handbrake-cli mediainfo-gui yt-dlp
sudo ${PACMAN_INSTALL} gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire

# Network
sudo ${PACMAN_INSTALL} gnome-browser-connector signal-desktop xdg-desktop-portal-gnome
sudo ${PACMAN_REMOVE_ALL} epiphany

# PIM
sudo ${PACMAN_INSTALL} geary

# System
sudo ${PACMAN_INSTALL} gptfdisk dosfstools e2fsprogs exfat-utils ntfs-3g hdparm nvme-cli

# Utilities
sudo ${PACMAN_INSTALL} p7zip man-db dmidecode rsync

## AUR USER APPLICATIONS
# Network
${AURMAN_INSTALL} microsoft-edge-stable-bin proton-vpn-gtk-app

## BASE DESKTOP APPLICATIONS
# System
${AURMAN_INSTALL} hardinfo2

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
