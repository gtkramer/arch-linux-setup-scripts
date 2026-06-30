#!/bin/bash
# Seal the root LUKS volume to the TPM2 (PCR 7) for password-less unlock; passphrase kept as recovery.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

require_root

usage() {
    echo "Usage: ${SCRIPT_NAME}"
    echo
    echo "  Seals a key for the root LUKS volume (${LUKS_NAME}) to the TPM2, bound to the Secure Boot"
    echo "  state (PCR 7). The LUKS passphrase is preserved as a recovery key."
    echo "  -h  Show this help message"
}

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

if [[ "${#}" -ne 0 ]]; then
    usage >&2
    die "This script does not accept positional arguments."
fi

if [[ ! -d /sys/firmware/efi ]]; then
    die "System is not booted in EFI mode."
fi

if [[ ! -e /dev/tpmrm0 ]]; then
    die "No TPM2 device (/dev/tpmrm0). Enable PTT/fTPM in firmware first."
fi

# PCR 7 only seals against the Secure Boot state, so the seal is only meaningful with Secure Boot on;
# otherwise an attacker booting unsigned code would satisfy the same measurement. Refuse rather than
# enroll a weak policy. PCR 7 (not 7+11) is deliberate: it survives kernel/initramfs updates without
# re-enrollment. Measuring the initramfs (PCR 11) needs a UKI and re-enrollment on every kernel bump.
if ! bootctl status 2>/dev/null | grep -q 'Secure Boot: enabled'; then
    die "Secure Boot is not enabled. Run secure-boot.sh first so the PCR 7 seal is meaningful."
fi

# systemd's TPM2 backend (dlopened by systemd-cryptsetup) plus inspection tooling.
pacman_install tpm2-tss tpm2-tools

# Resolve the backing partition of the opened root LUKS mapping.
luks_part_dev="$(cryptsetup status "${LUKS_NAME}" | awk '/device:/ {print $2}')"
if [[ -z "${luks_part_dev}" ]]; then
    die "Could not determine the backing device for ${LUKS_NAME}; is it open?"
fi

# Replace any prior TPM2 token and seal a fresh key to PCR 7; prompts once for an existing passphrase.
systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 "${luks_part_dev}"

# Rebuild so the initramfs carries the TPM2 libraries sd-encrypt needs to use the new token at boot.
mkinitcpio -P

echo "Sealed ${luks_part_dev} to the TPM2 (PCR 7); the LUKS passphrase remains as a recovery key."
echo "If the Secure Boot state changes, unlock with the passphrase and re-run this script."
