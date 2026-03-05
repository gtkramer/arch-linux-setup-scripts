#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../common.sh"

configs=(desktop system firewall bluetooth)
for config in "${configs[@]}"; do
    config_path="${SCRIPT_DIR}/${config}.sh"
    if [[ ! -e "${config_path}" ]]; then
        config_path="${SCRIPT_DIR}/${config}/install.sh"
    fi
    "${config_path}"
done
