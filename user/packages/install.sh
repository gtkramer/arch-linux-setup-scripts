#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

## PRODUCTIVITY
# Internet
sudo ${PACMAN_INSTALL} firefox thunderbird

# Development
sudo ${PACMAN_INSTALL} hugo

# Messaging
sudo ${PACMAN_INSTALL} signal-desktop

# Security
${AURMAN_INSTALL} protonvpn-gui protonvpn-cli

## EDIT
# Pictures
sudo ${PACMAN_INSTALL} pinta hugin dcraw qcad

# Videos
sudo ${PACMAN_INSTALL} handbrake mediainfo-gui

## VIEW AND PLAY
# Players
sudo ${PACMAN_INSTALL} haruna

# Frameworks
sudo ${PACMAN_INSTALL} gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire

## SYSTEM TOOLS
# Disk Management
sudo ${PACMAN_INSTALL} dosfstools e2fsprogs exfat-utils f2fs-tools hdparm

# System Administration
sudo ${PACMAN_INSTALL} man-db dmidecode

# Accessories
sudo ${PACMAN_INSTALL} p7zip

## OTHER
${AURMAN_INSTALL} archlinux-artwork yt-dlp

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
