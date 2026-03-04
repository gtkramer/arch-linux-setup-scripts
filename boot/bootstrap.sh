#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

usage() {
    local script_name
    script_name="$(basename "${0}")"
    echo "Usage: ${script_name} -b <block device>"
    echo
    echo "  -b  Specify the block device"
    echo "  -h  Show this help message"
}

# Parse parameters
BLOCK_DEV=""
while getopts "b:h" opt; do
    case "${opt}" in
        b)
            BLOCK_DEV="${OPTARG}"
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

# Configure boot via systemd-boot
bootctl install

mkdir -p /boot/loader/entries
cat > /boot/loader/loader.conf <<'EOF'
default arch-lts.conf
timeout 3
editor  no
EOF

cat > /boot/loader/entries/arch-lts.conf <<EOF
title   Arch Linux (LTS)
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts.img
options root=/dev/mapper/vg0-root quiet
EOF

cat > /boot/loader/entries/arch-lts-fallback.conf <<EOF
title   Arch Linux (LTS Fallback)
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts-fallback.img
options root=/dev/mapper/vg0-root quiet
EOF

# Configure hooks
sed -i '/^HOOKS=/d' /etc/mkinitcpio.conf
touch /etc/vconsole.conf
echo 'HOOKS=(systemd autodetect microcode modconf keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)' >> /etc/mkinitcpio.conf
mkinitcpio -p linux-lts

# Require password for privilege escalation
mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# Create users and set passwords
echo "Set password for root"
passwd root

useradd -m -G wheel -c "${DISPLAY_NAME}" "${USER_NAME}"
echo "Set password for ${USER_NAME}"
passwd "${USER_NAME}"

# Enable network to come up automatically
systemctl enable NetworkManager
