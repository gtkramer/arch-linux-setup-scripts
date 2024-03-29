#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

# Set time
timedatectl set-timezone "${TIMEZONE}"
timedatectl set-ntp true
timedatectl set-local-rtc 0

# Set language and keyboard
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen
localectl set-locale "LANG=${LOCALE}"
localectl --no-convert set-keymap "${KEYMAP}"
localectl --no-convert set-x11-keymap "${KEYMAP}"

# Set hostname
hostnamectl set-hostname "${HOSTNAME}"

# Enable TRIM for SSD
systemctl enable fstrim.timer
