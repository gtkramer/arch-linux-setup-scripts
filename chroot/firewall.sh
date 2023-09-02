#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_REMOVE} iptables
${PACMAN_INSTALL} ufw iptables-nft
systemctl enable --now ufw

ufw reset
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
