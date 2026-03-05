#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
readonly SCRIPT_DIR
. "${SCRIPT_DIR}/../../common.sh"

pacman_install cups hplip usbutils python-pyqt5 wget rpcbind
sudo systemctl enable --now cups.socket
hp-setup
