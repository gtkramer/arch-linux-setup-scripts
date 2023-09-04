#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

CONFIGS=(package-manager packages fonts devices settings terminal xdg virtualization)
for CONFIG in "${CONFIGS[@]}"; do
	CONFIG_PATH="${SCRIPT_DIR}/${CONFIG}.sh"
	if [ ! -e "${CONFIG_PATH}" ]; then
		CONFIG_PATH="${SCRIPT_DIR}/${CONFIG}/install.sh"
	fi
	"${CONFIG_PATH}"
done
