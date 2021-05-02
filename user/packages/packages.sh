#!/bin/bash
## PRODUCTIVITY
# Internet
sudo pacman -Sy --noconfirm firefox chrome-gnome-shell

# Development
aurman -Sy --noconfirm --noedit dotnet-sdk hugo shellcheck

## EDIT
# Pictures
sudo pacman -Sy --noconfirm gimp hugin gimp-nufraw

# Videos
sudo pacman -Sy --noconfirm handbrake

## VIEW AND PLAY
# Frameworks
# Switch to intel-media-driver from libva-intel-driver after getting a current Intel CPU
sudo pacman -Sy --noconfirm gstreamer gstreamer-vaapi libva-intel-driver gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav

## SYSTEM TOOLS
# Disk Management
sudo pacman -Sy --noconfirm dosfstools e2fsprogs exfat-utils f2fs-tools hdparm

# System Administration
aurman -Sy --noconfirm --noedit hardinfo-git dconf-editor man-db

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
