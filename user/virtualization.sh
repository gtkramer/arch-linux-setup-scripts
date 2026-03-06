#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

pacman_install gnome-boxes iptables-nft dnsmasq dmidecode edk2-ovmf swtpm
sudo systemctl enable --now libvirtd
swtpm_setup --create-config-files skip-if-exist
