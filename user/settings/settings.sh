#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Configure themes and fonts for GTK+ applications independent from GNOME desktop
sudo cp -f "$SCRIPT_DIR/settings.ini" /etc/gtk-3.0
sed '/^\[Settings\]/d' "$SCRIPT_DIR/settings.ini" | sudo tee /etc/gtk-2.0/gtkrc

# Configure themes and fonts for GNOME desktop
gsettings set org.gnome.desktop.interface cursor-size 16

gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Sans Bold 10.5'
gsettings set org.gnome.desktop.interface font-name 'Sans 10.5'
gsettings set org.gnome.desktop.interface document-font-name 'Serif 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 11'

# Configure other settings for GNOME desktop
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'hibernate'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
