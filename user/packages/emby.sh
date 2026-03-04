#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

pacman_install emby-server tesseract-data-eng
sudo systemctl enable --now emby-server
sudo ufw allow from 192.168.1.0/24 to any port 8096 proto tcp
