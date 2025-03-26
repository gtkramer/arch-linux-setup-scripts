#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../../parameters.sh"

${AURMAN_INSTALL} microsoft-edge-stable-bin
cp -f "${SCRIPT_DIR}/microsoft-edge-stable-flags.conf" "${HOME}/.config"
