#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

${AURMAN_INSTALL} yubico-authenticator-bin
sudo systemctl enable --now pcscd.socket
