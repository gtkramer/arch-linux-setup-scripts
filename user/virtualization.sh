#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

sudo pacman -S virt-manager qemu-desktop dnsmasq swtpm
sudo usermod -a -G wheel "${USER}"
sudo systemctl enable --now libvirtd
swtpm_setup --create-config-files skip-if-exist
