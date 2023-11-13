#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo ${PACMAN_INSTALL} dconf-editor

# Configure themes and fonts for GNOME desktop
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'

gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Sans Bold 10'
gsettings set org.gnome.desktop.interface font-name 'Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Serif 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 11'

# Configure other settings for GNOME desktop
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Configure night light for GNOME desktop
gsettings set org.gnome.system.location enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2700

# Sort folders before files in file chooser for GTK3 and GTK4
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
gsettings set org.gtk.Settings.FileChooser sort-directories-first true
