#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

cp -f "${SCRIPT_DIR}/.bash_profile_wayland" "${HOME}"
if ! grep -Fq '.bash_profile_wayland' "${HOME}/.bash_profile"; then
	echo '[[ -f ~/.bash_profile_wayland ]] && source ~/.bash_profile_wayland' >> "${HOME}/.bash_profile"
fi
