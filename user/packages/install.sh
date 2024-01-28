#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

## PRIMARY USER APPLICATIONS
# Development
sudo ${PACMAN_INSTALL} hugo clang lldb

# Graphics
sudo ${PACMAN_INSTALL} hugin dcraw qcad

# Multimedia
sudo ${PACMAN_INSTALL} celluloid ffmpegthumbnailer handbrake mediainfo-gui yt-dlp
sudo ${PACMAN_INSTALL} gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire gstreamer-vaapi onevpl-intel-gpu libva-utils
sudo ${PACMAN_REMOVE_ALL} gnome-music totem

# Network
sudo ${PACMAN_INSTALL} firefox gnome-browser-connector signal-desktop xdg-desktop-portal-gnome
sudo ${PACMAN_REMOVE_ALL} epiphany

# PIM
sudo ${PACMAN_INSTALL} geary

# System
sudo ${PACMAN_INSTALL} gptfdisk dosfstools e2fsprogs exfat-utils ntfs-3g hdparm nvme-cli

# Utilities
sudo ${PACMAN_INSTALL} p7zip man-db dmidecode rsync

## AUR USER APPLICATIONS
# Graphics
${AURMAN_INSTALL} archlinux-artwork

# Network
${AURMAN_INSTALL} protonvpn-gui protonvpn-cli network-manager-applet

## BASE DESKTOP APPLICATIONS
# System
${AURMAN_INSTALL} hardinfo-git

## CUSTOM PACKAGES
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PACKAGES=(vim git visual-studio-code dotnet tresorit)
for PACKAGE in "${PACKAGES[@]}"; do
    PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}.sh"
    if [ ! -e "${PACKAGE_PATH}" ]; then
        PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}/install.sh"
    fi
    "${PACKAGE_PATH}"
done
