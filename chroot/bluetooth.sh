#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../common.sh"

pacman_install bluez bluez-utils
systemctl enable bluetooth
