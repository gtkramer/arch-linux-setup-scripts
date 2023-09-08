#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

## PRIMARY USER APPLICATIONS
# Development
sudo ${PACMAN_INSTALL} hugo

# Graphics
sudo ${PACMAN_INSTALL} krita hugin dcraw qcad

# Multimedia
sudo ${PACMAN_INSTALL} vlc handbrake mediainfo-gui yt-dlp

# Network
sudo ${PACMAN_INSTALL} firefox signal-desktop

# PIM
sudo ${PACMAN_INSTALL} thunderbird

# System
sudo ${PACMAN_INSTALL} dosfstools e2fsprogs exfat-utils f2fs-tools hdparm

# Utilities
sudo ${PACMAN_INSTALL} p7zip man-db dmidecode rsync

## AUR USER APPLICATIONS
# Graphics
${AURMAN_INSTALL} archlinux-artwork

# Network
${AURMAN_INSTALL} protonvpn-gui protonvpn-cli

## BASE DESKTOP APPLICATIONS
# Graphics
sudo ${PACMAN_INSTALL} gwenview kdegraphics-thumbnailers okular spectacle svgpart

# Multimedia
sudo ${PACMAN_INSTALL} ffmpegthumbs

# System
sudo ${PACMAN_INSTALL} ksystemlog partitionmanager

# Utilities
sudo ${PACMAN_INSTALL} ark filelight kalk kate kcharselect kclock kdf kdialog kgpg kweather

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
