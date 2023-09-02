#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} print-manager system-config-printer cups hplip usbutils python-pyqt5
sudo systemctl enable --now cups.socket
hp-setup
