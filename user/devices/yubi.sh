#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

${AURMAN_INSTALL} yubico-authenticator-bin
sudo systemctl enable --now pcscd.socket
