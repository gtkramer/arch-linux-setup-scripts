#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../common.sh"

usage() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} [-d] [-c] <block device>"
    echo
    echo "  -d  Destroy all existing data"
    echo "  -c  Clean dot files and folders for all users in /home partition"
    echo "  -h  Show this help message"
}

# Parse parameters
destroy_data=false
clean_dot=false
while getopts "dch" opt; do
    case "${opt}" in
        d)
            destroy_data=true
            ;;
        c)
            clean_dot=true
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            usage >&2
            die "Invalid option: -${OPTARG}"
            ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -lt 1 ]]; then
    usage >&2
    die "Block device is required."
fi

block_dev="${1}"

if [[ ! -e "${block_dev}" ]]; then
    die "Block device ${block_dev} does not exist."
fi

if "${destroy_data}"; then
    warn "You have chosen to destroy all existing data. This operation is irreversible."
    echo "If you wish to abort this operation, press Ctrl+C within the next 5 seconds."
    sleep 5s
fi

# Update system clock
timedatectl set-ntp true

# Create physical partitions
if "${destroy_data}"; then
    sgdisk -Z "${block_dev}"
    sgdisk -n 1:1M:+512M -t 1:ef00 -c 1:boot "${block_dev}"
    block_end_sector="$(sgdisk -E "${block_dev}" | grep -P '^\d+$')"
    sgdisk -n 2:0:$(( block_end_sector - (block_end_sector + 1) % 2048 )) -t 2:8309 -c 2:crypt "${block_dev}"
    if ! sgdisk -v "${block_dev}"; then
        die "Physical partitions failed verification for ${block_dev}"
    fi
fi

if [[ ${block_dev} =~ ^/dev/nvme ]]; then
    block_part_prefix=p
else
    block_part_prefix=""
fi
boot_part="${block_dev}${block_part_prefix}1"
crypt_part="${block_dev}${block_part_prefix}2"

# Set up crypt device
if "${destroy_data}"; then
    cryptsetup -y -v luksFormat "${crypt_part}"
fi
crypt_dev=/dev/mapper/crypt
if [[ ! -e "${crypt_dev}" ]]; then
    if [[ "$(cat "/sys/block/$(basename "${block_dev}")/queue/rotational")" == 0 ]]; then
        block_crypt_opts=(--allow-discards --perf-no_read_workqueue --perf-no_write_workqueue)
    else
        block_crypt_opts=()
    fi
    cryptsetup "${block_crypt_opts[@]}" --persistent open "${crypt_part}" crypt
fi

vol_group=vg0
vol_dev="/dev/${vol_group}"
if "${destroy_data}"; then
    pvcreate "${crypt_dev}"
    vgcreate "${vol_group}" "${crypt_dev}"

    mem_total="$(grep MemTotal /proc/meminfo | awk '{print $2}')"
    lvcreate -L "${mem_total}K" "${vol_group}" -n swap
    lvcreate -L 64G "${vol_group}" -n root
    lvcreate -l 100%FREE "${vol_group}" -n home
else
    for _ in {1..10}; do
        if [[ -e "${vol_dev}" ]]; then
            break
        fi
        sleep 1s
    done
fi
if [[ ! -e "${vol_dev}" ]]; then
    die "${vol_dev} volume device does not exist"
fi

# Create file systems
mkfs.fat -F32 "${boot_part}"
mkfs.ext4 -F "${vol_dev}/root"
if "${destroy_data}"; then
    mkfs.ext4 -F "${vol_dev}/home"
fi
mkswap "${vol_dev}/swap"

# Mount file systems
mkdir -p /mnt
mount "${vol_dev}/root" /mnt
mkdir -p /mnt/boot
mount "${boot_part}" /mnt/boot
mkdir -p /mnt/home
mount "${vol_dev}/home" /mnt/home
swapon "${vol_dev}/swap"

# Configure mirrors
reflector --country "${COUNTRY_MIRROR}" --sort rate --protocol https --save /etc/pacman.d/mirrorlist

# Install system
pacstrap /mnt base base-devel linux-lts linux-firmware lvm2 intel-ucode efibootmgr networkmanager

# Configure file systems
fstab_file=/mnt/etc/fstab
genfstab -U /mnt >> "${fstab_file}"

crypttab_file=/mnt/etc/crypttab.initramfs
crypt_uuid="$(cryptsetup luksUUID "${crypt_part}")"
echo "crypt       UUID=${crypt_uuid}    none    luks" > "${crypttab_file}"

# Post install cleanup of dot files and folders in /home partition for all users
if "${clean_dot}"; then
    find /mnt/home -mindepth 2 -maxdepth 2 -name '.*' -exec rm -rf {} +
    find /mnt/home -mindepth 1 -maxdepth 1 -type d | while read -r home_dir; do
        rsync --chown="$(stat -c '%U:%G' "${home_dir}")" -a /mnt/etc/skel/ "${home_dir}/"
    done
fi
