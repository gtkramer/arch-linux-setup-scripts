#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../common.sh"

# Configure bootloader
bootctl install

mkdir -p /boot/loader/entries

cat > /boot/loader/entries/arch-lts.conf <<EOF
title   Arch Linux (LTS)
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts.img
options root=/dev/mapper/${VG_NAME}-${LV_ROOT} resume=/dev/mapper/${VG_NAME}-${LV_SWAP} quiet
EOF

cat > /boot/loader/entries/arch-lts-fallback.conf <<EOF
title   Arch Linux (LTS Fallback)
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts-fallback.img
options root=/dev/mapper/${VG_NAME}-${LV_ROOT} resume=/dev/mapper/${VG_NAME}-${LV_SWAP} quiet
EOF

cat > /boot/loader/loader.conf <<'EOF'
default arch-lts.conf
timeout 3
editor  no
EOF

mkdir -p /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/95-systemd-boot.hook <<EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Gracefully upgrading systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
EOF

# Configure boot hooks
sed -i '/^HOOKS=/d' /etc/mkinitcpio.conf
touch /etc/vconsole.conf
echo 'HOOKS=(systemd autodetect microcode modconf keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)' >> /etc/mkinitcpio.conf
mkinitcpio -p linux-lts

# Require password for privilege escalation
mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# Create users and set passwords
echo "Set password for root"
passwd root

useradd -m -G wheel -c "${DISPLAY_NAME}" "${USER_NAME}"
echo "Set password for ${USER_NAME}"
passwd "${USER_NAME}"

# Enable network to come up automatically
systemctl enable NetworkManager
