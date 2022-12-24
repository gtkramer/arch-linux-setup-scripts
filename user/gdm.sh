#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

sudo cp "${HOME}/.config/monitors.xml" ~gdm/.config/monitors.xml
sudo chown gdm:gdm ~gdm/.config/monitors.xml

sed 's/^[# ]*WaylandEnable.*$/WaylandEnable=false/' /etc/gdm/custom.conf
