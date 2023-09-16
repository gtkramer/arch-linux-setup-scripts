#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../../parameters.sh"

${AURMAN_INSTALL} visual-studio-code-bin
sudo cp -f "${SCRIPT_DIR}/98-visual-studio-code.conf" /usr/share/fontconfig/conf.avail
sudo ln -sf /usr/share/fontconfig/conf.avail/98-visual-studio-code.conf /etc/fonts/conf.d

mkdir -p "${HOME}/.config/Code/User"
cp -f "${SCRIPT_DIR}/settings.json" "${HOME}/.config/Code/User"
echo '--ozone-platform-hint=auto' >> "${HOME}/.config/code-flags.conf"
