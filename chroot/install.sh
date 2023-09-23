#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

CONFIGS=(desktop display-manager system firewall bluetooth)
for CONFIG in "${CONFIGS[@]}"; do
	CONFIG_PATH="${SCRIPT_DIR}/${CONFIG}.sh"
	if [ ! -e "${CONFIG_PATH}" ]; then
		CONFIG_PATH="${SCRIPT_DIR}/${CONFIG}/install.sh"
	fi
	"${CONFIG_PATH}"
done

passwd -l root
