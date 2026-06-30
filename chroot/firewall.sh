#!/bin/bash
# Enable a default-deny ufw firewall. Run as root.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

require_root

pacman_install gufw
systemctl enable ufw

ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
ufw logging on
ufw enable
