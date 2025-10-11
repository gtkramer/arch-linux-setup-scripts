#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} vim

touch "${HOME}/.vimrc"
truncate -s0 "${HOME}/.vimrc"
echo 'set spell' >> "${HOME}/.vimrc"
echo 'filetype plugin on' >> "${HOME}/.vimrc"
echo 'syntax on' >> "${HOME}/.vimrc"
