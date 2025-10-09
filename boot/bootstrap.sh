#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
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

# Configure boot
efibootmgr | sed -nr 's/^Boot([0-9A-Fa-f]{4}).*Linux.*$/\1/Ip' | while read -r BOOT_NUM; do
    efibootmgr -b "${BOOT_NUM}" -B
done
efibootmgr -c -d "${BLOCK_DEV}" -p 1 -L 'Arch Linux' -l /vmlinuz-linux -u 'root=/dev/mapper/vg0-root initrd=/initramfs-linux.img quiet'

# Configure hooks
sed -i '/^HOOKS=/d' /etc/mkinitcpio.conf
echo 'HOOKS=(systemd autodetect modconf keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)' >> /etc/mkinitcpio.conf
mkinitcpio -p linux

# Set up passwordless authentication based on group membership
mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

mkdir -p /etc/polkit-1/rules.d
cat > /etc/polkit-1/rules.d/49-nopasswd_global.rules <<EOF
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
EOF

# Create users and set passwords
echo "Set password for root"
passwd root

useradd -m -G wheel -c "${DISPLAY_NAME}" "${USERNAME}"
echo "Set password for ${USERNAME}"
passwd "${USERNAME}"

# Enable network to come up automatically
systemctl enable NetworkManager
