#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
readonly SCRIPT_DIR
. "${SCRIPT_DIR}/../../common.sh"

pacman_install smartmontools
sudo systemctl enable smartd

readonly NOTIFY_SCRIPT='/etc/smartmontools/smartd_warning.d/notify.sh'
sudo mkdir -p "$(dirname "${NOTIFY_SCRIPT}")"
sudo cp -f "${SCRIPT_DIR}/$(basename "${NOTIFY_SCRIPT}")" "${NOTIFY_SCRIPT}"
