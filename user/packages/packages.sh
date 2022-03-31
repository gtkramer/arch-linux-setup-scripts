#!/bin/bash
## PRODUCTIVITY
# Internet
aurman -Syu --noconfirm --noedit firefox chrome-gnome-shell

# Development
aurman -Syu --noconfirm --noedit dotnet-sdk hugo shellcheck

# Messaging
sudo pacman -Sy --noconfirm signal-desktop

# Security
aurman -Syu --noconfirm --noedit protonvpn-gui

## EDIT
# Pictures
sudo pacman -Sy --noconfirm pinta hugin dcraw

# Videos
sudo pacman -Sy --noconfirm handbrake

## VIEW AND PLAY
# Frameworks
sudo pacman -Sy --noconfirm gstreamer gstreamer-vaapi intel-media-driver gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav

## SYSTEM TOOLS
# Disk Management
sudo pacman -Sy --noconfirm dosfstools e2fsprogs exfat-utils f2fs-tools hdparm

# System Administration
aurman -Syu --noconfirm --noedit hardinfo-git dconf-editor man-db dmidecode

# Accessories
sudo pacman -Sy --noconfirm gnome-tweaks

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
