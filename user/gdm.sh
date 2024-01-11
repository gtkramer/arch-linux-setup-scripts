#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo mkdir -p ~gdm/.config/
sudo chown gdm:gdm ~gdm/.config/

sudo cp -f "${HOME}/.config/monitors.xml" ~gdm/.config/
sudo chown gdm:gdm ~gdm/.config/monitors.xml

run_as_gdm_user() {
    sudo -u gdm dbus-launch --exit-with-session "${@}"
}

run_as_gdm_user gsettings set org.gnome.system.location enabled true
run_as_gdm_user gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
run_as_gdm_user gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
run_as_gdm_user gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2700

run_as_gdm_user gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
run_as_gdm_user gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
run_as_gdm_user gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
