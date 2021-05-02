#!/bin/bash

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
efibootmgr -c -d "$BLOCK_DEV" -p 2 -L 'Arch Linux' -l /vmlinuz-linux -u 'root=/dev/disk/by-partlabel/root resume=/dev/disk/by-partlabel/swap rw initrd=/initramfs-linux.img quiet'
if ! grep -Pq '^HOOKS=.*resume' /etc/mkinitcpio.conf; then
	sed -r -i 's/fsck\)$/resume fsck\)/' /etc/mkinitcpio.conf
fi
if ! grep -Pq '^HOOKS=.*resume' /etc/mkinitcpio.conf; then
	echo "Did not add resume hook to initramfs!" >&2
	exit 1
fi
mkinitcpio -p linux
