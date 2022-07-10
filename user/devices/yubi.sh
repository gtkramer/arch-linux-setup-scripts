#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} yubioath-desktop
sudo systemctl enable --now pcscd.socket
