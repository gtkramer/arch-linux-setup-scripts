#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../common.sh"

usage() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} [-p] <block device>"
    echo
    echo "  -p  Preserve data in /home"
    echo "  -h  Show this help message"
}

# Parse parameters
preserve_home=false
while getopts "ph" opt; do
    case "${opt}" in
        p)
            preserve_home=true
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

if [[ "${#}" -ne 1 ]]; then
    usage >&2
    die "Exactly one block device is required."
fi

block_dev="${1}"

# Validate arguments
if [[ ! -e "${block_dev}" ]]; then
    die "Block device ${block_dev} does not exist."
fi

if blkid -p -s PTTYPE -o value "${block_dev}" &> /dev/null; then
    have_partitions=true
else
    have_partitions=false
fi

if "${preserve_home}" && ! "${have_partitions}"; then
    die "Cannot preserve data in /home on a block device without partitions."
fi

if ! "${preserve_home}" && "${have_partitions}"; then
    warn "All existing data in /home will be destroyed."
    echo "To abort this operation, press Ctrl+C within the next 10 seconds..."
    sleep 10s
fi

# Update system clock
timedatectl set-ntp true

# Create physical partitions
if ! "${preserve_home}"; then
    sgdisk -Z "${block_dev}"
    sgdisk -n 1:1M:+512M -t 1:ef00 "${block_dev}"
    last_usable_sector="$(sgdisk -E "${block_dev}" | grep -P '^\d+$')"
    sgdisk -n 2:0:$(( last_usable_sector - (last_usable_sector + 1) % 2048 )) -t 2:8309 "${block_dev}"
    if ! sgdisk -v "${block_dev}"; then
        die "Physical partitions failed verification for ${block_dev}."
    fi
fi

if [[ "${block_dev}" =~ ^/dev/nvme ]]; then
    part_separator=p
else
    part_separator=""
fi
boot_part_dev="${block_dev}${part_separator}1"
luks_part_dev="${block_dev}${part_separator}2"

# Set up LUKS device
if ! "${preserve_home}"; then
    cryptsetup -y -v luksFormat "${luks_part_dev}"
fi
luks_dev=/dev/mapper/${LUKS_NAME}
if [[ ! -e "${luks_dev}" ]]; then
    if [[ "$(cat "/sys/block/$(basename "${block_dev}")/queue/rotational")" == 0 ]]; then
        luks_open_opts=(--allow-discards --perf-no_read_workqueue --perf-no_write_workqueue)
    else
        luks_open_opts=()
    fi
    cryptsetup "${luks_open_opts[@]}" --persistent open "${luks_part_dev}" "${LUKS_NAME}"
fi

vg_dev="/dev/${VG_NAME}"
if ! "${preserve_home}"; then
    pvcreate "${luks_dev}"
    vgcreate "${VG_NAME}" "${luks_dev}"

    mem_total="$(grep MemTotal /proc/meminfo | awk '{print $2}')"
    lvcreate -L "${mem_total}K" "${VG_NAME}" -n "${LV_SWAP}"
    lvcreate -L 64G "${VG_NAME}" -n "${LV_ROOT}"
    lvcreate -l 100%FREE "${VG_NAME}" -n "${LV_HOME}"
else
    for _ in {1..10}; do
        if [[ -e "${vg_dev}" ]]; then
            break
        fi
        sleep 1s
    done
fi
if [[ ! -e "${vg_dev}" ]]; then
    die "${vg_dev} volume device does not exist."
fi

# Create file systems
mkfs.fat -F32 "${boot_part_dev}"
mkfs.ext4 -F "${vg_dev}/${LV_ROOT}"
if ! "${preserve_home}"; then
    mkfs.ext4 -F "${vg_dev}/${LV_HOME}"
fi
mkswap "${vg_dev}/${LV_SWAP}"

# Mount file systems
mkdir -p /mnt
mount "${vg_dev}/${LV_ROOT}" /mnt
mkdir -p /mnt/boot
mount -o fmask=0077,dmask=0077 "${boot_part_dev}" /mnt/boot    # Protect the random seed file for systemd-boot from being world-readable
mkdir -p /mnt/home
mount "${vg_dev}/${LV_HOME}" /mnt/home
swapon "${vg_dev}/${LV_SWAP}"

# Configure mirrors
reflector --country "${COUNTRY_MIRROR}" --sort rate --protocol https --save /etc/pacman.d/mirrorlist

# Install system
pacstrap /mnt base base-devel linux-lts linux-firmware lvm2 intel-ucode efibootmgr networkmanager

# Configure file systems
fstab_file=/mnt/etc/fstab
genfstab -U /mnt >> "${fstab_file}"

crypttab_file=/mnt/etc/crypttab.initramfs
luks_uuid="$(cryptsetup luksUUID "${luks_part_dev}")"
echo "${LUKS_NAME}       UUID=${luks_uuid}    none    luks" > "${crypttab_file}"

# Clean dot files and folders in /home partition for all users
find /mnt/home -mindepth 2 -maxdepth 2 -name '.*' -exec rm -rf {} +
find /mnt/home -mindepth 1 -maxdepth 1 -type d | while read -r home_dir; do
    rsync --chown="$(stat -c '%U:%G' "${home_dir}")" -a /mnt/etc/skel/ "${home_dir}/"
done
