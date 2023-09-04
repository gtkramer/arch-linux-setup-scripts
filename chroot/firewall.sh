#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_REMOVE} iptables
${PACMAN_INSTALL} ufw iptables-nft
systemctl enable ufw

ufw enable
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing

chmod 640 /etc/ufw/*.rules
