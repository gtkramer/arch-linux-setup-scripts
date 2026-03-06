#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

sudo mkdir -p ~gdm/{.config,.cache}/
sudo chown gdm:gdm ~gdm/{.config,.cache}/

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
