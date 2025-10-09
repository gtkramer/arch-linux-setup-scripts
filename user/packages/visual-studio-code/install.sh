#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../../parameters.sh"

${AURMAN_INSTALL} visual-studio-code-bin

mkdir -p "${HOME}/.config/Code/User"
cp -f "${SCRIPT_DIR}/settings.json" "${HOME}/.config/Code/User"
cp -f "${SCRIPT_DIR}/code-flags.conf" "${HOME}/.config"
