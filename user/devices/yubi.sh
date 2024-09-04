#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

gpg --recv-keys 20EE325B86A81BCBD3E56798F04367096FBA95E8
${AURMAN_INSTALL} yubico-authenticator-bin
sudo systemctl enable --now pcscd.socket
