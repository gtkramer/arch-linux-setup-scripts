#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Install Bluetooth components
pacman -Sy --noconfirm bluez bluez-utils bluez-plugins pulseaudio-bluetooth gnome-bluetooth gnome-user-share
systemctl enable bluetooth

# Automatically switch to Bluetooth headphones on connect
if ! grep -Pq '^load-module module-switch-on-connect$' /etc/pulse/default.pa; then
	echo 'load-module module-switch-on-connect' >> /etc/pulse/default.pa
fi

# Prevent GDM from capturing the A2DP sink on startup
mkdir -p ~gdm/.config/pulse
cp -f "$SCRIPT_DIR/default.pa" ~gdm/.config/pulse
chown -R gdm:gdm ~gdm/.config
