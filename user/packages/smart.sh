#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

pacman_install smartmontools
sudo systemctl enable smartd
