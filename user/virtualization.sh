#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

sudo pacman -S gnome-boxes iptables-nft dnsmasq dmidecode edk2-ovmf swtpm
sudo systemctl enable --now libvirtd.service
swtpm_setup --create-config-files skip-if-exist
