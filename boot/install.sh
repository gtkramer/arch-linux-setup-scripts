#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

usage() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} -b <block device> [-d]"
    echo
    echo "  -b  Specify the block device"
    echo "  -d  Destroy all existing data"
    echo "  -c  Clean dot files and folders for all users in /home partition"
    echo "  -h  Show this help message"
}

# Parse parameters
BLOCK_DEV=""
DESTROY_DATA=false
CLEAN_DOT=false
while getopts "b:dch" opt; do
    case "${opt}" in
        b)
            BLOCK_DEV="${OPTARG}"
            ;;
        d)
            DESTROY_DATA=true
            ;;
        c)
            CLEAN_DOT=true
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            usage >&2
            exit 1
            ;;
        :)
            echo "Option -${OPTARG} requires an argument." >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ -z "${BLOCK_DEV}" ]]; then
    echo "Error: Block device is required." >&2
    usage >&2
    exit 1
fi
if [[ ! -e "${BLOCK_DEV}" ]]; then
    echo "Error: Block device ${BLOCK_DEV} does not exist." >&2
    exit 1
fi

if "${DESTROY_DATA}"; then
    echo "WARNING: You have chosen to destroy all existing data. This operation is irreversible."
    echo "If you wish to abort this operation, press Ctrl+C within the next 5 seconds."
    sleep 5s
fi

# Update system clock
timedatectl set-ntp true

# Create physical partitions
if "${DESTROY_DATA}"; then
    sgdisk -Z "${BLOCK_DEV}"
    sgdisk -n 1:1M:+512M -t 1:ef00 -c 1:boot "${BLOCK_DEV}"
    BLOCK_END_SECTOR="$(sgdisk -E "${BLOCK_DEV}" | grep -P '^\d+$')"
    sgdisk -n 2:0:$(( BLOCK_END_SECTOR - (BLOCK_END_SECTOR + 1) % 2048 )) -t 2:8309 -c 2:crypt "${BLOCK_DEV}"
    if ! sgdisk -v "${BLOCK_DEV}"; then
        echo "Physical partitions failed verification for ${BLOCK_DEV}" >&2
        exit 1
    fi
fi

if [[ ${BLOCK_DEV} =~ ^/dev/nvme ]]; then
    BLOCK_PART_PREFIX=p
else
    BLOCK_PART_PREFIX=""
fi
BOOT_PART="${BLOCK_DEV}${BLOCK_PART_PREFIX}1"
CRYPT_PART="${BLOCK_DEV}${BLOCK_PART_PREFIX}2"

# Set up crypt device
if "${DESTROY_DATA}"; then
    cryptsetup -y -v luksFormat "${CRYPT_PART}"
fi
CRYPT_DEV=/dev/mapper/crypt
if [[ ! -e "${CRYPT_DEV}" ]]; then
    if [[ "$(cat "/sys/block/$(basename "${BLOCK_DEV}")/queue/rotational")" == 0 ]]; then
        BLOCK_CRYPT_OPTS="--allow-discards --perf-no_read_workqueue --perf-no_write_workqueue"
    else
        BLOCK_CRYPT_OPTS=""
    fi
    cryptsetup ${BLOCK_CRYPT_OPTS} --persistent open "${CRYPT_PART}" crypt
fi

VOL_GROUP=vg0
VOL_DEV="/dev/${VOL_GROUP}"
if "${DESTROY_DATA}"; then
    pvcreate "${CRYPT_DEV}"
    vgcreate "${VOL_GROUP}" "${CRYPT_DEV}"

    MEM_TOTAL="$(grep MemTotal /proc/meminfo | awk '{print $2}')"
    lvcreate -L "${MEM_TOTAL}K" "${VOL_GROUP}" -n swap
    lvcreate -L 64G "${VOL_GROUP}" -n root
    lvcreate -l 100%FREE "${VOL_GROUP}" -n home
else
    for _ in {1..10}; do
        if [[ -e "${VOL_DEV}" ]]; then
            break
        fi
        sleep 1s
    done
fi
if [[ ! -e "${VOL_DEV}" ]]; then
    echo "${VOL_DEV} volume device does not exist" >&2
    exit 1
fi

# Create file systems
mkfs.fat -F32 "${BOOT_PART}"
mkfs.ext4 -F "${VOL_DEV}/root"
if "${DESTROY_DATA}"; then
    mkfs.ext4 -F "${VOL_DEV}/home"
fi
mkswap "${VOL_DEV}/swap"

# Mount file systems
mkdir -p /mnt
mount "${VOL_DEV}/root" /mnt
mkdir -p /mnt/boot
mount "${BOOT_PART}" /mnt/boot
mkdir -p /mnt/home
mount "${VOL_DEV}/home" /mnt/home
swapon "${VOL_DEV}/swap"

# Configure mirrors
reflector --country "${COUNTRY_MIRROR}" --sort rate --protocol https --save /etc/pacman.d/mirrorlist

# Install system
pacstrap /mnt base base-devel linux-lts linux-firmware lvm2 intel-ucode efibootmgr networkmanager

# Configure file systems
FSTAB_FILE=/mnt/etc/fstab
genfstab -U /mnt >> "${FSTAB_FILE}"

CRYPTTAB_FILE=/mnt/etc/crypttab.initramfs
CRYPT_UUID="$(cryptsetup luksUUID "${CRYPT_PART}")"
echo "crypt       UUID=${CRYPT_UUID}    none    luks" > "${CRYPTTAB_FILE}"

# Post install cleanup of dot files and folders in /home partition for all users
if "${CLEAN_DOT}"; then
    find /mnt/home -mindepth 2 -maxdepth 2 -name '.*' -exec rm -rf {} +
    find /mnt/home -mindepth 1 -maxdepth 1 -type d | while read -r HOME_DIR; do
        rsync --chown="$(stat -c '%U:%G' "${HOME_DIR}")" -a /mnt/etc/skel/ "${HOME_DIR}/"
    done
fi
