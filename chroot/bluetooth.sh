#!/bin/bash
# Install Bluetooth components
pacman -Sy --noconfirm bluez bluez-utils bluez-plugins pulseaudio-bluetooth gnome-bluetooth gnome-user-share
systemctl enable bluetooth

# Automatically switch to Bluetooth headphones on connect
if ! grep -Pq '^load-module module-switch-on-connect$' /etc/pulse/default.pa; then
	echo 'load-module module-switch-on-connect' >> /etc/pulse/default.pa
fi
