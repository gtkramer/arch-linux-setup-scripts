#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

${AURMAN_INSTALL} wd719x-firmware aic94xx-firmware upd72020x-fw
mkinitcpio -p linux
