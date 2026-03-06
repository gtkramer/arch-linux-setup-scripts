#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/common.sh"

aur_install
mapfile -t orphaned_packages < <(pacman_list_orphans)
if [[ "${#orphaned_packages[@]}" -ne 0 ]]; then
    pacman_remove_all "${orphaned_packages[@]}"
fi
pacman_clean_cache
