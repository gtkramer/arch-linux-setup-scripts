#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

display_help() {
	local script_name
	script_name="$(basename "${0}")"
	echo "Usage: ${script_name} -b|--block <block device>"
}

PARAMS="$(getopt -o b:h -l block:,help --name "${0}" -- "${@}")"
eval set -- "${PARAMS}"

while true; do
    case "${1}" in
        -b|--block)
            BLOCK_DEV="${2}"
            shift 2
            ;;
        -h|--help)
            display_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            display_help >&2
            exit 1
            ;;
    esac
done

if [ -z "${BLOCK_DEV}" ]; then
	echo 'Parameter -b|--block is required' >&2
	exit 1
fi

# Update system clock
timedatectl set-ntp true

# Create partitions
sgdisk -Z "${BLOCK_DEV}"
sgdisk -n 1:1M:+128M -t 1:ef00 -c 1:boot "${BLOCK_DEV}"
sgdisk -n 2:0:0 -t 2:8304 -c 2:root "${BLOCK_DEV}"
if ! sgdisk -v "${BLOCK_DEV}"; then
	echo "Drive partitions failed verification for ${BLOCK_DEV}" >&2
	exit 1
fi

DEV_BOOT="${BLOCK_DEV}p1"
DEV_ROOT="${BLOCK_DEV}p2"

# Create file systems
mkfs.fat -F32 "${DEV_BOOT}"

cryptsetup -y -v luksFormat "${DEV_ROOT}"
cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent open "${DEV_ROOT}" root
MAP_ROOT=/dev/mapper/root
mkfs.ext4 -F "${MAP_ROOT}"

# Mount file systems
mkdir -p /mnt
mount "${MAP_ROOT}" /mnt
mkdir -p /mnt/boot
mount "${DEV_BOOT}" /mnt/boot

# Configure mirrors
${PACMAN_INSTALL} reflector
reflector --country "${COUNTRY_MIRROR}" --sort rate --protocol https --save /etc/pacman.d/mirrorlist

# Install system
pacstrap /mnt base base-devel linux linux-firmware

# Configure file systems
FSTAB_FILE=/mnt/etc/fstab
genfstab -L /mnt >> "${FSTAB_FILE}"

sed -r -i "s_^${MAP_ROOT}(\\s+\\S+){3}_&,discard_" "${FSTAB_FILE}"

sed -i "s_^${DEV_BOOT}_PARTLABEL=boot_" "${FSTAB_FILE}"
