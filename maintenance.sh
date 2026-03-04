#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/parameters.sh"

aurman_install --do_everything
mapfile -t orphaned_packages < <(sudo pacman -Qdtq || true)
if [[ "${#orphaned_packages[@]}" -ne 0 ]]; then
    sudo pacman -Rns --noconfirm "${orphaned_packages[@]}"
fi
sudo pacman -Sc --noconfirm
