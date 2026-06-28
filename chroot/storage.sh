#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

require_root

usage() {
    echo "Usage: ${SCRIPT_NAME} <block device 1> <block device 2>"
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
    warn "All existing data in ${DATA_MOUNT} will be destroyed."
    echo "To abort this operation, press Ctrl+C within the next 10 seconds..."
    sleep 10s
fi

# Set up all LUKS devices
declare -A dev_luks_map=(
    ["${block_dev_1}"]=${DATA_LUKS_NAME}0
    ["${block_dev_2}"]=${DATA_LUKS_NAME}1
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
    part="$(get_partition_dev "${block_dev}" 1)"

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

# Create the btrfs RAID1 mirror across the LUKS devices. btrfs is in the
# mainline kernel, so there is no out-of-tree module to lag behind kernel
# updates; raid1 mirrors both data and metadata with end-to-end checksums,
# so bit rot is detected and self-healed from the good copy on read/scrub.
# block-group-tree keeps mount times fast on a large (>4 TiB) array.
pacman_install btrfs-progs

mkfs.btrfs -f -L "${DATA_LABEL}" -O block-group-tree -d raid1 -m raid1 "${luks_devs[@]}"
btrfs device scan
udevadm settle

# Hold the data in a dedicated subvolume rather than the top-level (id 5)
# subvolume, so snapshots and future layout changes stay easy.
mkdir -p "${DATA_MOUNT}"
mount "${luks_devs[0]}" "${DATA_MOUNT}"
btrfs subvolume create "${DATA_MOUNT}/${DATA_SUBVOL}"
umount "${DATA_MOUNT}"

# Persist the subvolume mount in fstab. nofail keeps a degraded or missing
# mirror from blocking boot (mount it manually with -o degraded); the longer
# mount timeout absorbs the slower assembly of a large RAID1 array.
data_uuid="$(blkid -s UUID -o value "${luks_devs[0]}")"
fstab_file=/etc/fstab
sed -i "\#[[:space:]]${DATA_MOUNT}[[:space:]]#d" "${fstab_file}"
echo "UUID=${data_uuid}    ${DATA_MOUNT}    btrfs    subvol=/${DATA_SUBVOL},compress=zstd,noatime,nofail,x-systemd.mount-timeout=5min    0 0" >> "${fstab_file}"
systemctl daemon-reload
mount "${DATA_MOUNT}"

chown root:root "${DATA_MOUNT}"
chmod 1777 "${DATA_MOUNT}"

# Scrub the mirror monthly with the unit shipped in btrfs-progs (the @ instance
# is the escaped mount point; results are logged to the journal)
systemctl enable "btrfs-scrub@$(systemd-escape -p "${DATA_MOUNT}").timer"

# Hide the btrfs member devices from udisks2 since /data is a system mount
cat > /etc/udev/rules.d/69-data-member-hide.rules <<EOF
SUBSYSTEM=="block", ENV{DM_NAME}=="${DATA_LUKS_NAME}*", ENV{UDISKS_IGNORE}="1"
EOF
