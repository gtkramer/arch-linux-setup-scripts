#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
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

readonly ZFS_POOL=srv
readonly ZFS_MOUNT=/srv
readonly ARC_MAX_BYTES=17179869184  # 16 GB

usage() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} <block device 1> <block device 2>"
    echo
    echo "  Two storage HDDs to form a LUKS-encrypted ZFS mirror (e.g. /dev/sda /dev/sdb)"
    echo "  -h  Show this help message"
}

# ---------------------------------------------------------------------------
# Parse parameters
# ---------------------------------------------------------------------------
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

if [[ $# -lt 2 ]]; then
    usage >&2
    die "Two block devices are required."
fi

if [[ ! -e "${1}" ]]; then
    die "Block device ${1} does not exist."
fi
if [[ ! -e "${2}" ]]; then
    die "Block device ${2} does not exist."
fi

srv_dev_1="$(realpath "${1}")"
srv_dev_2="$(realpath "${2}")"

if [[ "${srv_dev_1}" == "${srv_dev_2}" ]]; then
    die "Both arguments resolve to the same device: ${srv_dev_1}"
fi

srv_devs=("${srv_dev_1}" "${srv_dev_2}")

declare -A srv_luks_map=(
    ["${srv_dev_1}"]=cryptsrv0
    ["${srv_dev_2}"]=cryptsrv1
)

warn "This will DESTROY ALL DATA on the following drives:"
echo "  ${srv_devs[0]}"
echo "  ${srv_devs[1]}"
echo "If you wish to abort, press Ctrl+C within the next 10 seconds."
sleep 10s

# ---------------------------------------------------------------------------
# Partition, encrypt, and open each storage drive
# ---------------------------------------------------------------------------
declare -A srv_parts
for disk in "${!srv_luks_map[@]}"; do
    name="${srv_luks_map[${disk}]}"

    echo ""
    echo "========================================"
    echo " Setting up ${disk} as ${name}"
    echo "========================================"

    # Wipe and create a single partition spanning the full drive
    sgdisk -Z "${disk}"
    end_sector="$(sgdisk -E "${disk}" | grep -P '^\d+$')"
    sgdisk -n 1:0:$(( end_sector - (end_sector + 1) % 2048 )) -t 1:8309 -c 1:"${name}" "${disk}"
    if ! sgdisk -v "${disk}"; then
        die "Physical partitions failed verification for ${disk}"
    fi

    # Determine the partition device path
    if [[ "${disk}" =~ ^/dev/nvme ]]; then
        part="${disk}p1"
    else
        part="${disk}1"
    fi

    # Wait for the partition device to appear
    udevadm settle
    for _ in {1..10}; do
        [[ -e "${part}" ]] && break
        sleep 1s
    done
    if [[ ! -e "${part}" ]]; then
        die "Partition ${part} did not appear."
    fi

    srv_parts["${disk}"]="${part}"

    # LUKS encrypt — cryptsetup prompts for a passphrase interactively
    cryptsetup -y -v luksFormat "${part}"

    # Open the LUKS container
    if [[ "$(cat "/sys/block/$(basename "${disk}")/queue/rotational")" == 0 ]]; then
        crypt_opts=(--allow-discards --perf-no_read_workqueue --perf-no_write_workqueue)
    else
        crypt_opts=()
    fi
    cryptsetup "${crypt_opts[@]}" --persistent open "${part}" "${name}"
done

# ---------------------------------------------------------------------------
# Register in /etc/crypttab.initramfs for automatic unlock at boot
#
# sd-encrypt tries each passphrase it has collected against every entry in
# crypttab.initramfs, so using the same passphrase as the boot drive means
# these volumes are unlocked without a second prompt.
# ---------------------------------------------------------------------------
crypttab_file=/etc/crypttab.initramfs
for disk in "${!srv_luks_map[@]}"; do
    name="${srv_luks_map[${disk}]}"
    srv_uuid="$(cryptsetup luksUUID "${srv_parts[${disk}]}")"
    if ! grep -q "^${name}" "${crypttab_file}" 2>/dev/null; then
        echo "${name}    UUID=${srv_uuid}    none    luks" >> "${crypttab_file}"
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

pacman_install zfs-linux-lts zfs-utils

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
mapper_devs=()
for name in "${srv_luks_map[@]}"; do
    mapper_devs+=("/dev/mapper/${name}")
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
    "${ZFS_POOL}" mirror "${mapper_devs[@]}"

chown "${USER_NAME}":"${USER_NAME}" "${ZFS_MOUNT}"

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

# ---------------------------------------------------------------------------
# Monthly ZFS scrub timer to detect and correct silent data corruption
# ---------------------------------------------------------------------------
cat > /etc/systemd/system/zfs-scrub@.timer <<'EOF'
[Unit]
Description=Monthly ZFS scrub on %i

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/zfs-scrub@.service <<'EOF'
[Unit]
Description=ZFS scrub on %i

[Service]
Type=oneshot
ExecStart=/usr/bin/zpool scrub %i
EOF

systemctl daemon-reload
systemctl enable zfs-scrub@${ZFS_POOL}.timer
