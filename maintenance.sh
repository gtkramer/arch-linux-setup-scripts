#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/parameters.sh"

${AURMAN_INSTALL} --do_everything
sudo pacman -Rns $(sudo pacman -Qdtq)
sudo pacman -Sc
