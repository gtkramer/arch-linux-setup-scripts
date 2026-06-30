#!/bin/bash
# Set timezone, locale, keymap, hostname, and enable periodic SSD TRIM. Run as root.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

require_root

# Set time
timedatectl set-timezone "${TIMEZONE}"
timedatectl set-ntp true
timedatectl set-local-rtc 0  # keep RTC in UTC; Windows matches via RealTimeIsUniversal (dual-boot)

# Set language and keyboard
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen
localectl set-locale "LANG=${LOCALE}"
localectl --no-convert set-keymap "${KEY_MAP}"
localectl --no-convert set-x11-keymap "${KEY_MAP}"

# Set hostname
hostnamectl set-hostname "${HOST_NAME}"

# Enable TRIM for SSD
systemctl enable fstrim.timer
