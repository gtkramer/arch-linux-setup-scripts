#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

require_root

usage() {
    echo "Usage: ${SCRIPT_NAME} [-e] [-k <keys directory>]"
    echo
    echo "  -e  Enroll keys in firmware (requires Setup Mode)"
    echo "  -k  Import existing keys from directory (PK/KEK/db layout)"
    echo "  -h  Show this help message"
}

ensure_sbctl_keys() {
    local import_keys_dir="${1}"
    if [[ -n "${import_keys_dir}" ]]; then
        if has_complete_sbctl_key_set "${import_keys_dir}"; then
            sbctl import-keys --directory "${import_keys_dir}" --force
        else
            die "Key directory to import ${import_keys_dir} is missing required sbctl keys."
        fi
    else
        if ! has_complete_sbctl_key_set "${SBCTL_KEYS_DIR}"; then
            if has_any_files "${SBCTL_KEYS_DIR}"; then
                die "Incomplete sbctl key set in ${SBCTL_KEYS_DIR}. Restore keys with -k or remove the partial keys first."
            fi
            sbctl create-keys
        fi
    fi
}

has_complete_sbctl_key_set() {
    local keys_dir="${1}"
    local key_file
    for key_file in "${SBCTL_KEY_FILES[@]}"; do
        if [[ ! -f "${keys_dir}/${key_file}" ]]; then
            return 1
        fi
    done
    return 0
}

has_any_files() {
    local dir="${1}"
    [[ -d "${dir}" ]] && [[ -n "$(find "${dir}" -type f -print -quit 2>/dev/null)" ]]
}

install_sign_script() {
    cat > /usr/local/sbin/secure-boot-sign <<'EOF'
#!/bin/bash
set -euo pipefail

die() {
    echo "ERROR: ${1}" >&2
    exit 1
}

if ! mountpoint -q /boot; then
    die "/boot is not mounted."
fi

mapfile -d '' efi_bins < <(
    find /boot -mindepth 1 -maxdepth 1 \( -type f -o -type l \) -name 'vmlinuz-*' -print0
)
if ((${#efi_bins[@]} == 0)); then
    die "No /boot/vmlinuz-* kernel images found."
fi

readonly systemd_efi_bin=/boot/EFI/systemd/systemd-bootx64.efi
readonly fallback_efi_bin=/boot/EFI/BOOT/BOOTX64.EFI
if [[ ! -f "${systemd_efi_bin}" ]]; then
    die "systemd-boot boot manager ${systemd_efi_bin} not found."
fi
if [[ ! -f "${fallback_efi_bin}" ]]; then
    die "Fallback EFI boot manager ${fallback_efi_bin} not found."
fi
efi_bins+=("${systemd_efi_bin}" "${fallback_efi_bin}")

for efi_bin in "${efi_bins[@]}"; do
    sbctl sign -s "${efi_bin}"
done
EOF
    chmod +x /usr/local/sbin/secure-boot-sign
}

install_pacman_hook() {
    mkdir -p /etc/pacman.d/hooks
    cat > /etc/pacman.d/hooks/99-secure-boot-sign.hook <<'EOF'
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux
Target = linux-lts
Target = linux-zen
Target = linux-hardened
Target = linux-rt
Target = linux-rt-lts
Target = systemd

[Action]
Description = Signing EFI binaries for Secure Boot...
When = PostTransaction
Exec = /usr/local/sbin/secure-boot-sign
Depends = sbctl
EOF
}

enroll_keys=false
import_keys_dir=
while getopts "ek:h" opt; do
    case "${opt}" in
        e)
            enroll_keys=true
            ;;
        k)
            import_keys_dir="${OPTARG}"
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

if [[ "${#}" -ne 0 ]]; then
    usage >&2
    die "This script does not accept positional arguments."
fi

if [[ ! -d /sys/firmware/efi ]]; then
    die "System is not booted in EFI mode."
fi

pacman_install sbctl

ensure_sbctl_keys "${import_keys_dir}"
install_sign_script
/usr/local/sbin/secure-boot-sign
if "${enroll_keys}"; then
    sbctl enroll-keys -m
fi

install_pacman_hook

sbctl status
sbctl verify || true
