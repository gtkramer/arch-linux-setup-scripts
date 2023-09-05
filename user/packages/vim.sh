#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} vim

if ! grep -Pq '^set spell$' "${HOME}/.vimrc"; then
	echo 'set spell' >> "${HOME}/.vimrc"
fi

if ! grep -Pq ' VISUAL=' "${HOME}/.bash_profile"; then
	echo 'export VISUAL=vim' >> "${HOME}/.bash_profile"
fi
