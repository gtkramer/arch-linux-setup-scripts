#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

configs=(printing yubi optical)
for config in "${configs[@]}"; do
    config_path="${SCRIPT_DIR}/${config}.sh"
    if [[ ! -e "${config_path}" ]]; then
        config_path="${SCRIPT_DIR}/${config}/install.sh"
    fi
    "${config_path}"
done
