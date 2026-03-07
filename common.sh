#!/bin/bash

readonly USER_NAME=george
readonly DISPLAY_NAME='George Kramer'
readonly GIT_NAME="${DISPLAY_NAME}"
readonly GIT_EMAIL=george.kramer@live.com
readonly GIT_EDITOR=vim
readonly TIMEZONE=America/Los_Angeles
readonly HOST_NAME=prowsw880acese
readonly LOCALE=en_US.UTF-8
readonly KEY_MAP=us
readonly COUNTRY_MIRROR='United States'
readonly LUKS_NAME=cryptlvm
readonly VG_NAME=vg0
readonly LV_ROOT=root
readonly LV_HOME=home
readonly LV_SWAP=swap
readonly ZFS_LUKS_NAME=cryptdata
readonly ZFS_POOL=data
readonly ZFS_ARC_MAX=17179869184
readonly ZFS_MOUNT=/data

die() {
    echo "ERROR: ${1}" >&2
    exit 1
}

warn() {
    echo "WARNING: ${1}" >&2
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

run_as_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        "${@}"
    else
        sudo "${@}"
    fi
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        die "Required to run as root or with sudo."
    fi
}

_pacman() { run_as_root pacman "${@}"; }
pacman_install() { _pacman -Syu --noconfirm "${@}"; }
pacman_remove() { _pacman --noconfirm -Rdd "${@}"; }
pacman_remove_all() { _pacman --noconfirm -Rns "${@}"; }
pacman_list_orphans() { _pacman -Qdtq 2>/dev/null || true; }
pacman_clean_cache() { _pacman -Sc --noconfirm; }

aur_install() { yay -Syu --noconfirm "${@}"; }

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

gpg_import_key() {
    gpg --recv-keys "${1}"
}

pacman_import_key() {
    run_as_root pacman-key --recv-keys "${1}"
    run_as_root pacman-key --lsign-key "${1}"
}
