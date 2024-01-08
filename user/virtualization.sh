#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo ${PACMAN_INSTALL} gnome-boxes iptables-nft dnsmasq dmidecode edk2-ovmf swtpm
sudo systemctl enable --now libvirtd
swtpm_setup --create-config-files skip-if-exist
