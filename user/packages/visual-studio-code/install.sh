#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../../common.sh"

aur_install visual-studio-code-bin

mkdir -p "${HOME}/.config/Code/User"
cp -f "${SCRIPT_DIR}/settings.json" "${HOME}/.config/Code/User"
cp -f "${SCRIPT_DIR}/code-flags.conf" "${HOME}/.config"
