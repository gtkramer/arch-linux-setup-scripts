#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../../parameters.sh"

${AURMAN_INSTALL} visual-studio-code-bin
sudo cp -f "${SCRIPT_DIR}/98-visual-studio-code.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/98-visual-studio-code.conf /etc/fonts/conf.d
