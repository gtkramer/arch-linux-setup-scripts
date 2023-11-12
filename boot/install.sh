#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

display_help() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} -b <block device> [-d]"
    echo
    echo "  -b  Specify the block device"
    echo "  -d  Destroy home"
    echo "  -h  Show this help message"
}

BLOCK_DEV=""
DESTROY_HOME=false

while getopts "b:dh" opt; do
    case "${opt}" in
        b)
            BLOCK_DEV="${OPTARG}"
            ;;
        d)
            DESTROY_HOME=true
            ;;
        h)
            display_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            display_help >&2
            exit 1
            ;;
        :)
            echo "Option -${OPTARG} requires an argument." >&2
            display_help >&2
            exit 1
            ;;
    esac
done

if [ -z "${BLOCK_DEV}" ]; then
    echo "Error: Block device is required." >&2
    display_help >&2
    exit 1
fi

if "${DESTROY_HOME}"; then
    echo "WARNING: You have chosen to destroy all data in /home. This operation is irreversible."
    echo "If you wish to abort this operation, press Ctrl+C within the next 5 seconds."
    sleep 5s
fi

# Update system clock
timedatectl set-ntp true

# Create physical partitions
if "${DESTROY_HOME}"; then
    sgdisk -Z "${BLOCK_DEV}"
    sgdisk -n 1:1M:+256M -t 1:ef00 -c 1:boot "${BLOCK_DEV}"
    END_SECTOR="$(sgdisk -E "${BLOCK_DEV}")"
    sgdisk -n 2:0:$(( END_SECTOR - (END_SECTOR + 1) % 2048 )) -t 2:8309 -c 2:crypt "${BLOCK_DEV}"
    if ! sgdisk -v "${BLOCK_DEV}"; then
        echo "Physical partitions failed verification for ${BLOCK_DEV}" >&2
        exit 1
    fi
fi

if [[ ${BLOCK_DEV} =~ ^/dev/nvme ]]; then
    PARTITION_PREFIX=p
else
    PARTITION_PREFIX=""
fi
DEV_BOOT="${BLOCK_DEV}${PARTITION_PREFIX}1"
DEV_CRYPT="${BLOCK_DEV}${PARTITION_PREFIX}2"

# Set up boot device
mkfs.fat -F32 "${DEV_BOOT}"

# Set up crypt device
if "${DESTROY_HOME}"; then
    cryptsetup -y -v luksFormat "${DEV_CRYPT}"
fi
CRYPT_DEV=/dev/mapper/crypt
if [[ ! -e "${CRYPT_DEV}" ]]; then
    cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent open "${DEV_CRYPT}" crypt
fi

VOL_GROUP=vg1
VOL_DEV="/dev/${VOL_GROUP}"
if "${DESTROY_HOME}"; then
    pvcreate "${CRYPT_DEV}"
    vgcreate "${VOL_GROUP}" "${CRYPT_DEV}"

    MEM_TOTAL="$(grep MemTotal /proc/meminfo | awk '{print $2}')"
    lvcreate -L "${MEM_TOTAL}K" "${VOL_GROUP}" -n swap
    lvcreate -L 64G "${VOL_GROUP}" -n root
    lvcreate -l 100%FREE "${VOL_GROUP}" -n home
else
    for i in {1..10}; do
        if [[ -e "${VOL_DEV}" ]]; then
            break
        fi
        sleep 1s
    done
fi
if [[ ! -e "${VOL_DEV}" ]]; then
    echo "${VOL_DEV} did not appear after 10 seconds" >&2
    exit 1
fi

mkfs.ext4 -F "${VOL_DEV}/root"
if "${DESTROY_HOME}"; then
    mkfs.ext4 -F "${VOL_DEV}/home"
fi
mkswap "${VOL_DEV}/swap"

# Mount file systems
mkdir -p /mnt
mount "${VOL_DEV}/root" /mnt
mkdir -p /mnt/boot
mount "${DEV_BOOT}" /mnt/boot
mkdir -p /mnt/home
mount "${VOL_DEV}/home" /mnt/home
swapon "${VOL_DEV}/swap"

# Configure mirrors
reflector --country "${COUNTRY_MIRROR}" --sort rate --protocol https --save /etc/pacman.d/mirrorlist

# Install system
pacstrap /mnt base base-devel linux linux-firmware lvm2 efibootmgr networkmanager

# Configure file systems
FSTAB_FILE=/mnt/etc/fstab
genfstab -L /mnt >> "${FSTAB_FILE}"

sed -i "s_^${DEV_BOOT}_PARTLABEL=boot_" "${FSTAB_FILE}"
