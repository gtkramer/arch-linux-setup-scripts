#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} cups hplip usbutils python-pyqt5 wget rpcbind
sudo systemctl enable --now cups.socket
hp-setup
