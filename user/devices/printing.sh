#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../common.sh"

pacman_install cups hplip usbutils python-pyqt5 wget rpcbind
sudo systemctl enable --now cups.socket
hp-setup
