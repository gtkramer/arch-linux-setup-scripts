#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

pacman_install gnome-boxes iptables-nft dnsmasq dmidecode edk2-ovmf swtpm
sudo systemctl enable --now libvirtd
swtpm_setup --create-config-files skip-if-exist
