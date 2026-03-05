#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../common.sh"

gpg --recv-keys 20EE325B86A81BCBD3E56798F04367096FBA95E8
aur_install yubico-authenticator-bin
sudo systemctl enable --now pcscd.socket
