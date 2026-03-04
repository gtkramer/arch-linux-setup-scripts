#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

# ============================================================================
# LUKS-encrypted ZFS mirror on two HDDs, mounted at /srv
#
# This is a standalone script that can be run at any time (not only during
# initial OS installation). It performs every step needed to go from two
# bare drives to a bootable, auto-mounting, encrypted ZFS mirror:
#
#   1. Partitions both drives
#   2. LUKS-encrypts each partition (prompts for a passphrase, same as boot)
#   3. Opens the LUKS containers
#   4. Registers drives in /etc/crypttab.initramfs so sd-encrypt auto-unlocks
#      them at boot using the same passphrase as the boot drive
#   5. Installs ZFS from the archzfs repository
#   6. Limits the ARC cache to 16 GB (suitable for a 128 GB RAM system)
#   7. Creates a mirrored ZFS pool on the opened LUKS containers
#   8. Enables ZFS services for automatic import and mount at boot
#
# UUIDs in crypttab.initramfs ensure drives are identified correctly even
# if their physical connection points on the motherboard change.
# ============================================================================

ZFS_POOL=srv
ZFS_MOUNT=/srv
ARC_MAX_BYTES=17179869184  # 16 GB

usage() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} -s <block device> -t <block device>"
    echo
    echo "  -s  First storage HDD  (e.g. /dev/sda)"
    echo "  -t  Second storage HDD (e.g. /dev/sdb)"
    echo "  -h  Show this help message"
}

# ---------------------------------------------------------------------------
# Parse parameters
# ---------------------------------------------------------------------------
SRV_DEV_1=""
SRV_DEV_2=""
while getopts "s:t:h" opt; do
    case "${opt}" in
        s)
            SRV_DEV_1="${OPTARG}"
            ;;
        t)
            SRV_DEV_2="${OPTARG}"
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

if [[ -z "${SRV_DEV_1}" ]]; then
    echo "Error: First storage device (-s) is required." >&2
    usage >&2
    exit 1
fi
if [[ ! -e "${SRV_DEV_1}" ]]; then
    echo "Error: Block device ${SRV_DEV_1} does not exist." >&2
    exit 1
fi

if [[ -z "${SRV_DEV_2}" ]]; then
    echo "Error: Second storage device (-t) is required." >&2
    usage >&2
    exit 1
fi
if [[ ! -e "${SRV_DEV_2}" ]]; then
    echo "Error: Block device ${SRV_DEV_2} does not exist." >&2
    exit 1
fi

SRV_DEVS=("${SRV_DEV_1}" "${SRV_DEV_2}")

declare -A SRV_LUKS_MAP=(
    ["${SRV_DEV_1}"]=cryptsrv0
    ["${SRV_DEV_2}"]=cryptsrv1
)

echo "WARNING: This will DESTROY ALL DATA on the following drives:"
echo "  ${SRV_DEVS[0]}"
echo "  ${SRV_DEVS[1]}"
echo "If you wish to abort, press Ctrl+C within the next 10 seconds."
sleep 10s

# ---------------------------------------------------------------------------
# Partition, encrypt, and open each storage drive
# ---------------------------------------------------------------------------
declare -A SRV_PARTS
for DISK in "${!SRV_LUKS_MAP[@]}"; do
    NAME="${SRV_LUKS_MAP[${DISK}]}"

    echo ""
    echo "========================================"
    echo " Setting up ${DISK} as ${NAME}"
    echo "========================================"

    # Wipe and create a single partition spanning the full drive
    sgdisk -Z "${DISK}"
    END_SECTOR="$(sgdisk -E "${DISK}" | grep -P '^\d+$')"
    sgdisk -n 1:0:$(( END_SECTOR - (END_SECTOR + 1) % 2048 )) -t 1:8309 -c 1:"${NAME}" "${DISK}"
    if ! sgdisk -v "${DISK}"; then
        echo "Physical partitions failed verification for ${DISK}" >&2
        exit 1
    fi

    # Determine the partition device path
    if [[ "${DISK}" =~ ^/dev/nvme ]]; then
        PART="${DISK}p1"
    else
        PART="${DISK}1"
    fi

    # Wait for the partition device to appear
    udevadm settle
    for _ in {1..10}; do
        [[ -e "${PART}" ]] && break
        sleep 1s
    done
    if [[ ! -e "${PART}" ]]; then
        echo "Error: Partition ${PART} did not appear." >&2
        exit 1
    fi

    SRV_PARTS["${DISK}"]="${PART}"

    # LUKS encrypt — cryptsetup prompts for a passphrase interactively
    cryptsetup -y -v luksFormat "${PART}"

    # Open the LUKS container
    if [[ "$(cat "/sys/block/$(basename "${DISK}")/queue/rotational")" == 0 ]]; then
        CRYPT_OPTS="--allow-discards --perf-no_read_workqueue --perf-no_write_workqueue"
    else
        CRYPT_OPTS=""
    fi
    cryptsetup ${CRYPT_OPTS} --persistent open "${PART}" "${NAME}"
done

# ---------------------------------------------------------------------------
# Register in /etc/crypttab.initramfs for automatic unlock at boot
#
# sd-encrypt tries each passphrase it has collected against every entry in
# crypttab.initramfs, so using the same passphrase as the boot drive means
# these volumes are unlocked without a second prompt.
# ---------------------------------------------------------------------------
CRYPTTAB_FILE=/etc/crypttab.initramfs
for DISK in "${!SRV_LUKS_MAP[@]}"; do
    NAME="${SRV_LUKS_MAP[${DISK}]}"
    SRV_UUID="$(cryptsetup luksUUID "${SRV_PARTS[${DISK}]}")"
    if ! grep -q "^${NAME}" "${CRYPTTAB_FILE}" 2>/dev/null; then
        echo "${NAME}    UUID=${SRV_UUID}    none    luks" >> "${CRYPTTAB_FILE}"
    fi
done

# Rebuild initramfs so sd-encrypt picks up the new crypttab entries
mkinitcpio -P

# ---------------------------------------------------------------------------
# Install ZFS from the archzfs repository
# ---------------------------------------------------------------------------
if ! grep -q '\[archzfs\]' /etc/pacman.conf; then
    pacman-key --recv-keys --keyserver keyserver.ubuntu.com \
        DDF7DB817396A49B2A2723F7403BD972F75D9D76
    pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76

    cat >> /etc/pacman.conf <<'EOF'

[archzfs]
Server = https://archzfs.com/$repo/$arch
EOF
fi

${PACMAN_INSTALL} zfs-linux-lts zfs-utils

# ---------------------------------------------------------------------------
# Limit ARC cache to 16 GB so the remaining RAM is available for applications
# ---------------------------------------------------------------------------
cat > /etc/modprobe.d/zfs.conf <<EOF
options zfs zfs_arc_max=${ARC_MAX_BYTES}
EOF

modprobe zfs

# ---------------------------------------------------------------------------
# Create ZFS mirror pool with settings optimized for large video files
# ---------------------------------------------------------------------------
MAPPER_DEVS=()
for NAME in "${SRV_LUKS_MAP[@]}"; do
    MAPPER_DEVS+=("/dev/mapper/${NAME}")
done

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
    "${ZFS_POOL}" mirror "${MAPPER_DEVS[@]}"

chown "${USERNAME}":"${USERNAME}" "${ZFS_MOUNT}"

# ---------------------------------------------------------------------------
# Persist the ZFS pool cache so it is auto-imported on boot
# ---------------------------------------------------------------------------
mkdir -p /etc/zfs
zpool set cachefile=/etc/zfs/zpool.cache "${ZFS_POOL}"

# ---------------------------------------------------------------------------
# Ensure ZFS pool import waits for LUKS containers to be opened
# ---------------------------------------------------------------------------
mkdir -p /etc/systemd/system/zfs-import-cache.service.d
cat > /etc/systemd/system/zfs-import-cache.service.d/after-cryptsetup.conf <<'EOF'
[Unit]
After=cryptsetup.target
Requires=cryptsetup.target
EOF

# ---------------------------------------------------------------------------
# Enable ZFS services for automatic import and mount
# ---------------------------------------------------------------------------
systemctl daemon-reload
systemctl enable zfs-import-cache
systemctl enable zfs-mount
systemctl enable zfs.target

echo ""
echo "========================================"
echo " ZFS storage setup complete"
echo "========================================"
echo " Pool:    ${ZFS_POOL} (mirror)"
echo " Mount:   ${ZFS_MOUNT}"
echo " Drives:  ${SRV_DEVS[*]}"
echo " ARC max: $(( ARC_MAX_BYTES / 1024 / 1024 / 1024 )) GB"
echo ""
echo " Reboot for sd-encrypt to auto-unlock"
echo " these drives with your boot passphrase."
echo "========================================"
