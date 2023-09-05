#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo ${PACMAN_INSTALL} virt-manager qemu-desktop dnsmasq swtpm
sudo systemctl enable --now libvirtd
swtpm_setup --create-config-files skip-if-exist
