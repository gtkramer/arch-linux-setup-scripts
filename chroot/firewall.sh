#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

pacman_remove iptables
pacman_install gufw iptables-nft
systemctl enable ufw

ufw enable
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
ufw logging on
