#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} vim

touch "${HOME}/.vimrc"
if ! grep -Pq '^set spell$' "${HOME}/.vimrc"; then
    echo 'set spell' >> "${HOME}/.vimrc"
fi

touch "${HOME}/.bash_profile"
if ! grep -Pq ' VISUAL=' "${HOME}/.bash_profile"; then
    echo 'export VISUAL=vim' >> "${HOME}/.bash_profile"
fi
