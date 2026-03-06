#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

configs=(desktop system firewall bluetooth)
for config in "${configs[@]}"; do
    config_path="${SCRIPT_DIR}/${config}.sh"
    if [[ ! -e "${config_path}" ]]; then
        config_path="${SCRIPT_DIR}/${config}/install.sh"
    fi
    "${config_path}"
done
