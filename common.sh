#!/usr/bin/env bash

readonly USER_NAME=george
readonly DISPLAY_NAME='George Kramer'
readonly GIT_NAME="${DISPLAY_NAME}"
readonly GIT_EMAIL=george.kramer@live.com
readonly GIT_EDITOR=vim
readonly TIMEZONE=America/Los_Angeles
readonly HOST_NAME=tufb660mplus
readonly LOCALE=en_US.UTF-8
readonly KEY_MAP=us
readonly COUNTRY_MIRROR='United States'

die() {
    echo "ERROR: ${1}" >&2
    exit 1
}

warn() {
    echo "WARNING: ${1}" >&2
}

_run_as_root() {
    if [[ ${EUID} -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

pacman_install() { _run_as_root pacman -Syu --noconfirm "$@"; }
pacman_remove() { _run_as_root pacman --noconfirm -Rdd "$@"; }
pacman_remove_all() { _run_as_root pacman --noconfirm -Rns "$@"; }
aurman_install() { aurman -Syu --noconfirm --noedit "$@"; }

manual_aur_install() {
    local git_url="${1}"
    shift

    local temp_dir
    temp_dir="$(mktemp -d)"
    git clone "${git_url}" "${temp_dir}"
    pushd "${temp_dir}" || exit
    makepkg --noconfirm -sri "$@"
    popd || exit
    rm -rf "${temp_dir}"
}
