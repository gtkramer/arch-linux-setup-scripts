#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
readonly SCRIPT_DIR
. "${SCRIPT_DIR}/../common.sh"

usage() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} <block device 1> <block device 2>"
    echo
    echo "  -h  Show this help message"
}

# Parse parameters
while getopts "h" opt; do
    case "${opt}" in
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

if [[ "${#}" -ne 2 ]]; then
    usage >&2
    die "Exactly two block devices are required."
fi

block_dev_1="${1}"
block_dev_2="${2}"

# Validate arguments
if [[ ! -e "${block_dev_1}" ]]; then
    die "Block device ${block_dev_1} does not exist."
fi
if [[ ! -e "${block_dev_2}" ]]; then
    die "Block device ${block_dev_2} does not exist."
fi

if [[ "${block_dev_1}" == "${block_dev_2}" ]]; then
    die "Block devices must be different."
fi

if has_partition_table "${block_dev_1}" || has_partition_table "${block_dev_2}"; then
    warn "All existing data in ${ZFS_MOUNT} will be destroyed."
    echo "To abort this operation, press Ctrl+C within the next 10 seconds..."
    sleep 10s
fi

# Set up all LUKS devices
declare -A dev_luks_map=(
    ["${block_dev_1}"]=${ZFS_LUKS_NAME}0
    ["${block_dev_2}"]=${ZFS_LUKS_NAME}1
)

luks_devs=()
for block_dev in "${!dev_luks_map[@]}"; do
    luks_name="${dev_luks_map[${block_dev}]}"
    luks_devs+=("/dev/mapper/${luks_name}")

    # Create physical partitions
    sgdisk -Z "${block_dev}"
    last_usable_sector="$(sgdisk -E "${block_dev}" | grep -P '^\d+$')"
    sgdisk -n 1:0:$(( last_usable_sector - (last_usable_sector + 1) % 2048 )) -t 1:8309 "${block_dev}"
    if ! sgdisk -v "${block_dev}"; then
        die "Physical partitions failed verification for ${block_dev}."
    fi

    # Wait for the partition device to appear
    partprobe "${block_dev}"
    udevadm settle

    # Determine the partition device path
    if [[ "${block_dev}" =~ ^/dev/nvme ]]; then
        part="${block_dev}p1"
    else
        part="${block_dev}1"
    fi

    # Set up LUKS device
    cryptsetup -y -v luksFormat "${part}"

    if [[ "$(cat "/sys/block/$(basename "${block_dev}")/queue/rotational")" == 0 ]]; then
        luks_open_opts=(--allow-discards --perf-no_read_workqueue --perf-no_write_workqueue)
    else
        luks_open_opts=()
    fi
    cryptsetup "${luks_open_opts[@]}" --persistent open "${part}" "${luks_name}"

    # Enable unlocking LUKS device at boot
    crypttab_file=/etc/crypttab.initramfs
    luks_uuid="$(cryptsetup luksUUID "${part}")"
    sed -i "/^${luks_name}/d" "${crypttab_file}"
    echo "${luks_name}    UUID=${luks_uuid}    none    luks" >> "${crypttab_file}"
done

mkinitcpio -P

# Install ZFS module
pacman_import_key 3A9917BF0DED5C13F69AC68FABEC0A1208037BE9

if ! grep -q "\[archzfs\]" /etc/pacman.conf; then
    cat >> /etc/pacman.conf <<'EOF'

[archzfs]
Server = https://github.com/archzfs/archzfs/releases/download/experimental
EOF
fi

pacman_install zfs-linux-lts zfs-utils

# Load ZFS module
mkdir -p /etc/modprobe.d
echo "options zfs zfs_arc_max=${ZFS_ARC_MAX}" > /etc/modprobe.d/zfs.conf
modprobe zfs

# Create ZFS mirror pool
zpool create -f \
    -o ashift=12 \
    -o autotrim=off \
    -O acltype=posixacl \
    -O xattr=sa \
    -O dnodesize=auto \
    -O atime=off \
    -O compression=lz4 \
    -O recordsize=1M \
    -m "${ZFS_MOUNT}" \
    "${ZFS_POOL}" mirror "${luks_devs[@]}"

mkdir -p /etc/zfs
zpool set cachefile=/etc/zfs/zpool.cache "${ZFS_POOL}"

sudo chown root:root "${ZFS_MOUNT}"
sudo chmod 1777 "${ZFS_MOUNT}"

# Enable ZFS services for automatic import and mount
systemctl enable zfs.target
systemctl enable zfs-import.target
systemctl enable zfs-import-cache
systemctl enable zfs-mount
systemctl enable "zfs-scrub-monthly@${ZFS_POOL}.timer"
