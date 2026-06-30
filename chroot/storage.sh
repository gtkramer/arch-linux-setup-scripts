#!/bin/bash
# Build an encrypted btrfs RAID1 data pool, auto-unlocked post-boot from a root keyfile (DESTRUCTIVE).
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

for block_dev in "${block_dev_1}" "${block_dev_2}"; do
    if has_partition_table "${block_dev}"; then
        confirm_data_destruction "${block_dev}"
    fi
done

# Set up all LUKS devices
declare -A dev_luks_map=(
    ["${block_dev_1}"]=${DATA_LUKS_NAME}0
    ["${block_dev_2}"]=${DATA_LUKS_NAME}1
)

luks_devs=()
for block_dev in "${!dev_luks_map[@]}"; do
    luks_name="${dev_luks_map[${block_dev}]}"
    luks_devs+=("/dev/mapper/${luks_name}")

    # Create physical partitions, ending the encrypted partition on a 1 MiB
    # boundary. On drives reporting a 4096-byte physical sector, cryptsetup
    # formats the LUKS payload with 4 KiB sectors, so its size must be a whole
    # multiple of that or luksFormat rounds it down (and warns); 1 MiB suffices.
    sgdisk -Z "${block_dev}"
    last_usable_sector="$(sgdisk -E "${block_dev}" | grep -P '^\d+$')"  # -E prints prose on some HDDs
    sgdisk -n "1:0:$(( last_usable_sector - (last_usable_sector + 1) % 2048 ))" -t 1:8309 "${block_dev}"
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

    if [[ "$(< "/sys/block/$(basename "${block_dev}")/queue/rotational")" == 0 ]]; then
        luks_open_opts=(--allow-discards --perf-no_read_workqueue --perf-no_write_workqueue)
    else
        luks_open_opts=()
    fi
    cryptsetup "${luks_open_opts[@]}" --persistent open "${part}" "${luks_name}"

    # Auto-unlock post-boot from a keyfile on the encrypted root
    keyfile="/etc/cryptsetup-keys.d/${luks_name}.key"
    if [[ ! -f "${keyfile}" ]]; then
        ( umask 077; mkdir -p /etc/cryptsetup-keys.d; head -c 256 /dev/urandom > "${keyfile}" )
    fi
    cryptsetup luksAddKey "${part}" "${keyfile}"

    luks_uuid="$(cryptsetup luksUUID "${part}")"
    crypttab_file=/etc/crypttab
    sed -i "/^${luks_name}[[:space:]]/d" "${crypttab_file}"
    echo "${luks_name}    UUID=${luks_uuid}    ${keyfile}    luks,nofail" >> "${crypttab_file}"
done

# Install btrfs tools
pacman_install btrfs-progs

# Create btrfs mirror
mkfs.btrfs -f -L "${DATA_LABEL}" --csum xxhash -d raid1 -m raid1 "${luks_devs[@]}"

# Register the mirror's member devices
btrfs device scan
udevadm settle

# Enable mounting at boot
data_uuid="$(blkid -s UUID -o value "${luks_devs[0]}")"
fstab_file=/etc/fstab
sed -i "\#[[:space:]]${DATA_MOUNT}[[:space:]]#d" "${fstab_file}"
echo "UUID=${data_uuid}    ${DATA_MOUNT}    btrfs    compress=zstd,noatime,nofail,x-systemd.mount-timeout=5min    0 0" >> "${fstab_file}"

# Scrub the mirror monthly
systemctl enable "btrfs-scrub@$(systemd-escape -p "${DATA_MOUNT}").timer"

# Set ownership and ACLs on the data root
mkdir -p "${DATA_MOUNT}"
mount "${DATA_MOUNT}"
groupadd -rf "${DATA_GROUP}"
if id "${USER_NAME}" &> /dev/null; then
    gpasswd -a "${USER_NAME}" "${DATA_GROUP}"
fi
chown "root:${DATA_GROUP}" "${DATA_MOUNT}"
chmod 2775 "${DATA_MOUNT}"
setfacl    -m g:"${DATA_GROUP}":rwX "${DATA_MOUNT}"
setfacl -d -m g:"${DATA_GROUP}":rwX "${DATA_MOUNT}"
umount "${DATA_MOUNT}"

# Hide btrfs member devices from udisks2 since they are not mountable drives
cat > /etc/udev/rules.d/69-data-member-hide.rules <<EOF
SUBSYSTEM=="block", ENV{DM_NAME}=="${DATA_LUKS_NAME}*", ENV{UDISKS_IGNORE}="1"
EOF
