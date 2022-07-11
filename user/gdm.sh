#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

sudo cp "${HOME}/.config/monitors.xml" ~gdm/.config/monitors.xml
sudo chown gdm:gdm ~gdm/.config/monitors.xml
sudo -u gdm dbus-launch gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
