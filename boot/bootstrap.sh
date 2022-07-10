#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/../parameters.sh"

display_help() {
	local script_name
	script_name="$(basename "$0")"
	echo "Usage: $script_name -b <block device>"
}

while getopts 'b:h' OPT; do
	case "$OPT" in
		b)
			BLOCK_DEV="$OPTARG"
			;;
		h)
			display_help
			exit 0
			;;
		*)
			echo 'Unrecognized option!' >&2
			display_help
			exit 1
			;;
	esac
done

if [ -z "$BLOCK_DEV" ]; then
	echo 'Parameter -b is required!' >&2
	display_help
	exit 1
fi

# Configure boot
pacman -Sy --noconfirm efibootmgr
efibootmgr | sed -nr 's/^Boot([[:digit:]]+).*Linux$/\1/p' | while read -r BOOT_NUM; do
	efibootmgr -b "$BOOT_NUM" -B
done
efibootmgr -c -d "$BLOCK_DEV" -p 1 -L 'Arch Linux' -l /vmlinuz-linux -u 'cryptdevice=PARTLABEL=root:root root=/dev/mapper/root rw initrd=/initramfs-linux.img nvidia-drm.modeset=1 quiet'

# Configure hooks
sed -i '/^HOOKS=/d' /etc/mkinitcpio.conf
echo 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)' >> /etc/mkinitcpio.conf
mkinitcpio -p linux

# Create users and set passwords
echo "Set password for root"
passwd root

mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
useradd -m -G wheel -c "$DISPLAY_NAME" "$USERNAME"
echo "Set password for $USERNAME"
passwd "$USERNAME"

# Enable network to come up automatically
pacman -Sy --noconfirm networkmanager
systemctl enable NetworkManager
