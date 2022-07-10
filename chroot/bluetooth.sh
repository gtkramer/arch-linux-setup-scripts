#!/bin/bash
pacman -Sy --noconfirm bluez bluez-utils bluez-plugins gnome-bluetooth gnome-user-share
systemctl enable bluetooth
