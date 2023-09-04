#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

display_help() {
	local script_name
	script_name="$(basename "${0}")"
	echo "Usage: ${script_name} -b|--block <block device>"
}

PARAMS="$(getopt -o b:h -l block:,help --name "${0}" -- "${@}")"
eval set -- "${PARAMS}"

while true; do
    case "${1}" in
        -b|--block)
            BLOCK_DEV="${2}"
            shift 2
            ;;
        -h|--help)
            display_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            display_help >&2
            exit 1
            ;;
    esac
done

if [ -z "${BLOCK_DEV}" ]; then
	echo 'Parameter -b|--block is required' >&2
	exit 1
fi

# Configure boot
efibootmgr | sed -nr 's/^Boot([[:digit:]]+).*Linux$/\1/p' | while read -r BOOT_NUM; do
	efibootmgr -b "${BOOT_NUM}" -B
done
efibootmgr -c -d "${BLOCK_DEV}" -p 1 -L 'Arch Linux' -l /vmlinuz-linux -u 'cryptdevice=PARTLABEL=crypt:crypt root=/dev/mapper/vg1-root resume=/dev/mapper/vg1-swap rw initrd=/initramfs-linux.img quiet'

# Configure hooks
sed -i '/^HOOKS=/d' /etc/mkinitcpio.conf
echo 'HOOKS=(base udev keyboard keymap consolefont autodetect modconf block encrypt lvm2 resume filesystems fsck)' >> /etc/mkinitcpio.conf
mkinitcpio -p linux

# Set up passwordless authentication based on group membership
mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

mkdir -p /etc/polkit-1/rules.d
cat > /etc/polkit-1/rules.d/49-nopasswd_global.rules <<-EOF
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
