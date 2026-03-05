#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../common.sh"

pacman_remove iptables
pacman_install gufw iptables-nft
systemctl enable ufw

ufw enable
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
ufw logging on
