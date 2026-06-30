#!/bin/bash
# Install the BlueZ stack and enable the Bluetooth service. Run as root.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

require_root

pacman_install bluez bluez-utils
systemctl enable bluetooth
