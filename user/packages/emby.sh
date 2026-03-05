#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
readonly SCRIPT_DIR
. "${SCRIPT_DIR}/../../common.sh"

pacman_install emby-server tesseract-data-eng
sudo systemctl enable --now emby-server

# Install UFW application profile for Emby
sudo mkdir -p /etc/ufw/applications.d
sudo tee /etc/ufw/applications.d/emby > /dev/null <<'EOF'
[Emby]
title=Emby Media Server
description=Emby media server LAN access
ports=8096/tcp
EOF
sudo ufw app update Emby
sudo ufw allow from 192.168.1.0/24 to any app Emby
