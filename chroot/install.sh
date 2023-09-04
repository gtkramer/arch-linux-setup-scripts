#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

CONFIGS=(desktop system terminal firewall bluetooth)
for CONFIG in "${CONFIGS[@]}"; do
	CONFIG_PATH="${SCRIPT_DIR}/${CONFIG}.sh"
	if [ ! -e "${CONFIG_PATH}" ]; then
		CONFIG_PATH="${SCRIPT_DIR}/${CONFIG}/${CONFIG}.sh"
	fi
	"${CONFIG_PATH}"
done

passwd -l root
