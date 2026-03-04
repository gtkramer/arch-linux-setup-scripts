#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

# Set time
timedatectl set-timezone "${TIMEZONE}"
timedatectl set-ntp true
timedatectl set-local-rtc 0

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
