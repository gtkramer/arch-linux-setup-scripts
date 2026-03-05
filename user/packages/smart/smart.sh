#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../common.sh"

pacman_install smartmontools
sudo systemctl enable smartd

readonly NOTIFY_SCRIPT='/etc/smartmontools/smartd_warning.d/notify.sh'
sudo mkdir -p "$(dirname "${NOTIFY_SCRIPT}")"
sudo cp -f "${SCRIPT_DIR}/$(basename "${NOTIFY_SCRIPT}")" "${NOTIFY_SCRIPT}"
