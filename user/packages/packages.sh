#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

## PRODUCTIVITY
# Internet
${AURMAN_INSTALL} firefox chrome-gnome-shell

# Development
${AURMAN_INSTALL} dotnet-sdk hugo shellcheck

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
# Frameworks
sudo ${PACMAN_INSTALL} gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav gst-plugin-pipewire

## SYSTEM TOOLS
# Disk Management
sudo ${PACMAN_INSTALL} dosfstools e2fsprogs exfat-utils f2fs-tools hdparm

# System Administration
${AURMAN_INSTALL} hardinfo-git dconf-editor man-db dmidecode

# Accessories
sudo ${PACMAN_INSTALL} gnome-tweaks

## OTHER
aurman -Syu archlinux-artwork

## CUSTOM PACKAGES
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PACKAGES=(vim git visual-studio-code tresorit spotify)
for PACKAGE in "${PACKAGES[@]}"; do
	PACKAGE_PATH="$SCRIPT_DIR/$PACKAGE.sh"
	if [ ! -e "$PACKAGE_PATH" ]; then
		PACKAGE_PATH="$SCRIPT_DIR/$PACKAGE/$PACKAGE.sh"
	fi
	"$PACKAGE_PATH"
done
