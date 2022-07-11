#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/parameters.sh"

${AURMAN_INSTALL} --do_everything
mapfile -t ORPHANED_PACKAGES < <(sudo pacman -Qdtq)
if [[ "${#ORPHANED_PACKAGES[@]}" -ne 0 ]]; then
    sudo pacman -Rns "${ORPHANED_PACKAGES[@]}"
fi
printf "Y\nY\n" | sudo pacman -Sc
