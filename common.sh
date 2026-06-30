#!/bin/bash
# Shared configuration and helper functions, sourced by every script.

readonly USER_NAME=george
readonly DISPLAY_NAME='George Kramer'
readonly USER_SHELL=/bin/bash
readonly GIT_NAME="${DISPLAY_NAME}"
readonly GIT_EMAIL=george.kramer@live.com
readonly GIT_EDITOR=vim
readonly TIMEZONE=America/Los_Angeles
readonly HOST_NAME=prowsw880acese
readonly LOCALE=en_US.UTF-8
readonly KEY_MAP=us
readonly COUNTRY_MIRROR='United States'
readonly TRUSTED_LAN_CIDR=192.168.1.0/24
readonly LUKS_NAME=cryptlvm
readonly VG_NAME=vg0
readonly LV_ROOT=root
readonly LV_HOME=home
readonly LV_SWAP=swap
readonly DATA_LUKS_NAME=cryptdata
readonly DATA_LABEL=data
readonly DATA_MOUNT=/data
readonly DATA_GROUP=data
readonly SBCTL_KEYS_DIR=/var/lib/sbctl/keys
readonly -a SBCTL_KEY_FILES=(
    PK/PK.key
    PK/PK.pem
    KEK/KEK.key
    KEK/KEK.pem
    db/db.key
    db/db.pem
)

die() {
    echo "ERROR: ${1}" >&2
    exit 1
}

warn() {
    echo "WARNING: ${1}" >&2
}

confirm_data_destruction() {
    local target="${1}" reply
    warn "This will DESTROY all data on: ${target}"
    read -r -p "Type the target exactly (${target}) to proceed, anything else aborts: " reply
    [[ "${reply}" == "${target}" ]] || die "Aborted; confirmation did not match."
}

has_partition_table() {
    blkid -p -s PTTYPE -o value "${1}" &> /dev/null
}

get_partition_dev() {
    local block_dev="${1}" part_num="${2}"
    if [[ "${block_dev}" =~ ^/dev/nvme ]]; then
        echo "${block_dev}p${part_num}"
    else
        echo "${block_dev}${part_num}"
    fi
}

run_as_user() {
    local user="${1}"; shift
    if [[ "${user}" == root ]]; then
        if [[ "${EUID}" -eq 0 ]]; then "${@}"; else sudo "${@}"; fi
    else
        sudo -u "${user}" "${@}"
    fi
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        die "Required to run as root or with sudo."
    fi
}

_pacman() { run_as_user root pacman "${@}"; }
pacman_install() { _pacman -Syu --needed --noconfirm "${@}"; }
pacman_remove() { _pacman --noconfirm -Rs "${@}"; }
pacman_remove_all() { _pacman --noconfirm -Rns "${@}"; }
pacman_list_orphans() { _pacman -Qdtq 2>/dev/null || true; }
pacman_clean_cache() { _pacman -Sc --noconfirm; }

aur_install() { yay -Syu --needed --noconfirm "${@}"; }
system_update() { yay -Syu --needed --noconfirm; }

manual_aur_install() {
    local git_url="${1}"
    shift

    local temp_dir
    temp_dir="$(mktemp -d)"
    git clone "${git_url}" "${temp_dir}"
    pushd "${temp_dir}" || exit
    makepkg --noconfirm -sri "${@}"
    popd || exit
    rm -rf "${temp_dir}"
}

run_scripts() {
    local base_dir="${1}"
    shift
    local name
    for name in "${@}"; do
        local script="${base_dir}/${name}.sh"
        if [[ ! -e "${script}" ]]; then
            script="${base_dir}/${name}/install.sh"
        fi
        "${script}"
    done
}

gpg_import_key() {
    gpg --recv-keys "${1}"
}

_pacman_key() { run_as_user root pacman-key "${@}"; }
pacman_import_key() {
    _pacman_key --recv-keys "${1}"
    _pacman_key --lsign-key "${1}"
}

# gsettings needs a private session bus to apply changes outside a logged-in
# GNOME session. Expand as "${GSETTINGS[@]}" to run as the current user, or
# run_as_user <name> "${GSETTINGS[@]}" to apply settings for another account.
readonly -a GSETTINGS=(dbus-launch --exit-with-session gsettings)
