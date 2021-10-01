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
localectl set-keymap "$KEYMAP"

# Set hostname
hostnamectl set-hostname "$HOSTNAME"

# Create users and set passwords
echo "Set password for root"
passwd root

mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
useradd -m -G wheel -c "$DISPLAY_NAME" "$USERNAME"
echo "Set password for $USERNAME"
passwd "$USERNAME"
