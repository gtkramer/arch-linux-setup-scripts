#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

${PACMAN_REMOVE} iptables
${PACMAN_INSTALL} gufw iptables-nft
systemctl enable ufw

ufw enable
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
