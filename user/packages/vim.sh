#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} vim

if ! grep -Pq '^set spell$' /etc/vimrc; then
	echo 'set spell' | sudo tee -a /etc/vimrc > /dev/null
fi

if ! grep -Pq ' VISUAL=' "${HOME}/.bash_profile"; then
	echo "export VISUAL=vim" >> "${HOME}/.bash_profile"
fi
