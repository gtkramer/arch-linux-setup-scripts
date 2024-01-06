#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo mkdir -p ~gdm/.config/
sudo chown gdm:gdm ~gdm/.config/

sudo cp -f "${HOME}/.config/monitors.xml" ~gdm/.config/
sudo chown gdm:gdm ~gdm/.config/monitors.xml
