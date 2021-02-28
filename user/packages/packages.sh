#!/bin/bash
## PRODUCTIVITY
# Internet
sudo pacman -Sy --noconfirm firefox chrome-gnome-shell

# Communications
sudo pacman -Sy --noconfirm polari

# Office
aurman -Sy --noconfirm --noedit libreoffice-fresh

# Development
aurman -Sy --noconfirm --noedit dotnet-sdk hugo

## EDIT
# Text
sudo pacman -Sy --noconfirm gedit

# Pictures
sudo pacman -Sy --noconfirm gimp hugin gimp-nufraw

# Videos
sudo pacman -Sy --noconfirm handbrake

## VIEW AND PLAY
# Viewers
sudo pacman -Sy --noconfirm evince eog

# Players
sudo pacman -Sy --noconfirm vlc ffmpegthumbnailer

# Frameworks
sudo pacman -Sy --noconfirm gstreamer gstreamer-vaapi libva-intel-driver gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav

## SYSTEM TOOLS
# File Management
sudo pacman -Sy --noconfirm nautilus file-roller p7zip baobab

# Disk Management
sudo pacman -Sy --noconfirm gnome-disk-utility dosfstools e2fsprogs exfat-utils f2fs-tools hdparm

# System Administration
aurman -Sy --noconfirm --noedit gnome-terminal gnome-system-monitor hardinfo-git dconf-editor gnome-logs man-db

# Accessories
sudo pacman -Sy --noconfirm gnome-font-viewer gnome-characters gnome-screenshot gnome-calculator gnome-tweaks cheese simple-scan gnome-clocks yelp

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

## REMOVE EXTRA PACKAGES
sudo pacman -Rns --noconfirm epiphany gnome-software gnome-boxes gnome-maps gnome-music gnome-photos gnome-weather gnome-todo totem gnome-documents gnome-calendar gnome-books gnome-contacts gnome-dictionary
