#!/bin/bash
# Apply the user's GNOME settings (theme, fonts, power, night light) via gsettings.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

pacman_install dconf-editor

# Configure themes and fonts for GNOME desktop
"${GSETTINGS[@]}" set org.gnome.desktop.interface cursor-theme 'Adwaita'
"${GSETTINGS[@]}" set org.gnome.desktop.interface gtk-theme 'Adwaita'

"${GSETTINGS[@]}" set org.gnome.desktop.wm.preferences titlebar-font 'Sans Bold 11'
"${GSETTINGS[@]}" set org.gnome.desktop.interface font-name 'Sans 11'
"${GSETTINGS[@]}" set org.gnome.desktop.interface document-font-name 'Serif 11'
"${GSETTINGS[@]}" set org.gnome.desktop.interface monospace-font-name 'Monospace 11'

# Configure other settings for GNOME desktop
"${GSETTINGS[@]}" set org.gnome.desktop.interface clock-format '12h'
"${GSETTINGS[@]}" set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
"${GSETTINGS[@]}" set org.gnome.shell always-show-log-out true
"${GSETTINGS[@]}" set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
"${GSETTINGS[@]}" set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
"${GSETTINGS[@]}" set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Configure night light for GNOME desktop
"${GSETTINGS[@]}" set org.gnome.system.location enabled true
"${GSETTINGS[@]}" set org.gnome.settings-daemon.plugins.color night-light-enabled true
"${GSETTINGS[@]}" set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
"${GSETTINGS[@]}" set org.gnome.settings-daemon.plugins.color night-light-temperature 2700

# Sort folders before files in file chooser for GTK3 and GTK4
"${GSETTINGS[@]}" set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
"${GSETTINGS[@]}" set org.gtk.Settings.FileChooser sort-directories-first true
