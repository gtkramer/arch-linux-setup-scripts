#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_INSTALL} powerline powerline-fonts

if ! grep -q powerline-daemon /etc/skel/.bashrc; then
	cat >> /etc/skel/.bashrc << EOF
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh
EOF
fi

if ! grep -q vte.sh /etc/skel/.bashrc; then
	echo '. /etc/profile.d/vte.sh' >> /etc/skel/.bashrc
fi
