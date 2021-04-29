#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CONFIGS=(system package-manager ramdisk firewall kernel terminal desktop network bluetooth touchpad)
for CONFIG in "${CONFIGS[@]}"; do
	CONFIG_PATH="$SCRIPT_DIR/$CONFIG.sh"
	if [ ! -e "$CONFIG_PATH" ]; then
		CONFIG_PATH="$SCRIPT_DIR/$CONFIG/$CONFIG.sh"
	fi
	"$CONFIG_PATH"
done
