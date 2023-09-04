#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_INSTALL} powerline powerline-fonts vte-common

if ! grep -q powerline-daemon "${HOME}/.bashrc"; then
	cat >> "${HOME}/.bashrc" << EOF
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh
EOF
fi

if ! grep -q vte.sh "${HOME}/.bashrc"; then
	echo '. /etc/profile.d/vte.sh' >> "${HOME}/.bashrc"
fi
