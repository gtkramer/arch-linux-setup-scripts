#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_INSTALL} bluez bluez-utils bluez-plugins gnome-bluetooth-3.0
systemctl enable bluetooth
