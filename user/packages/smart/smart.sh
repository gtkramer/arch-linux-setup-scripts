#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../../common.sh"

pacman_install smartmontools
sudo systemctl enable smartd

notify_script='/etc/smartmontools/smartd_warning.d/notify.sh'
sudo mkdir -p "$(dirname "${notify_script}")"
sudo cp -f "${SCRIPT_DIR}/$(basename "${notify_script}")" "${notify_script}"
