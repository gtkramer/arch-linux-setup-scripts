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

# Update system clock
timedatectl set-ntp true

# Create partitions
sgdisk -Z "$BLOCK_DEV"
sgdisk -n 1:1M:+8G -t 1:8200 -c 1:swap "$BLOCK_DEV"
sgdisk -n 2:0:+128M -t 2:ef00 -c 2:boot "$BLOCK_DEV"
sgdisk -n 3:0:+16G -t 3:8304 -c 3:root "$BLOCK_DEV"
sgdisk -n 4:0:0 -t 4:8302 -c 4:home "$BLOCK_DEV"
if ! sgdisk -v "$BLOCK_DEV"; then
	echo "Drive partitions failed verification for ${BLOCK_DEV}!" >&2
	exit 1
fi

# Create file systems
mkswap "${BLOCK_DEV}1"
mkfs.fat -F32 "${BLOCK_DEV}2"
mkfs.ext4 -F "${BLOCK_DEV}3"
mkfs.ext4 -F "${BLOCK_DEV}4"

# Mount file systems
swapon "${BLOCK_DEV}1"
mkdir -p /mnt
mount "${BLOCK_DEV}3" /mnt
mkdir -p /mnt/boot
mount "${BLOCK_DEV}2" /mnt/boot
mkdir -p /mnt/home
mount "${BLOCK_DEV}4" /mnt/home

# Configure mirrors
pacman -Sy --noconfirm reflector
reflector --country "$COUNTRY_MIRROR" --sort rate --protocol https --save /etc/pacman.d/mirrorlist

# Install system
pacstrap /mnt base base-devel linux linux-firmware

# Configure file systems
FSTAB_FILE=/mnt/etc/fstab
genfstab -L /mnt >> "$FSTAB_FILE"

sed -r -i "s_^${BLOCK_DEV}3(\\s+\\S+){3}_&,discard_" "$FSTAB_FILE"
sed -r -i "s_^${BLOCK_DEV}4(\\s+\\S+){3}_&,discard_" "$FSTAB_FILE"

sed -i "s_^${BLOCK_DEV}1_PARTLABEL=swap_" "$FSTAB_FILE"
sed -i "s_^${BLOCK_DEV}2_PARTLABEL=boot_" "$FSTAB_FILE"
sed -i "s_^${BLOCK_DEV}3_PARTLABEL=root_" "$FSTAB_FILE"
sed -i "s_^${BLOCK_DEV}4_PARTLABEL=home_" "$FSTAB_FILE"
