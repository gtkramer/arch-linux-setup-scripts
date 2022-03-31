#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/../parameters.sh"

# Set time
timedatectl set-timezone "$TIMEZONE"
timedatectl set-ntp true
timedatectl set-local-rtc 0

# Set language and keyboard
sed -i "s/^#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen
localectl set-locale "LANG=$LOCALE"
localectl --no-convert set-keymap "$KEYMAP"
localectl --no-convert set-x11-keymap "$KEYMAP"

# Set hostname
hostnamectl set-hostname "$HOSTNAME"

