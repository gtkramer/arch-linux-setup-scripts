#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

## PRIMARY USER APPLICATIONS
# Development
sudo ${PACMAN_INSTALL} hugo

# Graphics
sudo ${PACMAN_INSTALL} pinta hugin dcraw qcad

# Multimedia
sudo ${PACMAN_INSTALL} celluloid ffmpegthumbnailer handbrake mediainfo-gui yt-dlp
sudo ${PACMAN_INSTALL} intel-media-driver libva-utils gstreamer gstreamer-vaapi gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire
sudo ${PACMAN_REMOVE_ALL} gnome-music totem

# Network
sudo ${PACMAN_INSTALL} signal-desktop xdg-desktop-portal-gnome

# Office
sudo ${PACMAN_INSTALL} libreoffice-fresh

# System
sudo ${PACMAN_INSTALL} dosfstools e2fsprogs exfat-utils ntfs-3g hdparm nvme-cli

# Utilities
sudo ${PACMAN_INSTALL} p7zip man-db dmidecode rsync

## AUR USER APPLICATIONS
# Graphics
${AURMAN_INSTALL} archlinux-artwork

# Network
${AURMAN_INSTALL} protonvpn-gui protonvpn-cli

## BASE DESKTOP APPLICATIONS
# System
${AURMAN_INSTALL} hardinfo-git

## CUSTOM PACKAGES
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PACKAGES=(firefox thunderbird vim git visual-studio-code dotnet tresorit)
for PACKAGE in "${PACKAGES[@]}"; do
    PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}.sh"
    if [ ! -e "${PACKAGE_PATH}" ]; then
        PACKAGE_PATH="${SCRIPT_DIR}/${PACKAGE}/install.sh"
    fi
    "${PACKAGE_PATH}"
done
