export USERNAME=george
export DISPLAY_NAME='George Kramer'
export GIT_NAME="${DISPLAY_NAME}"
export GIT_EMAIL=george.kramer@live.com
export GIT_EDITOR=vim
export TIMEZONE=America/Los_Angeles
export HOSTNAME=tufb660mplus
export LOCALE=en_US.UTF-8
export KEYMAP=us
export COUNTRY_MIRROR='United States'
export PACMAN_REMOVE='pacman --noconfirm -Rdd'
export PACMAN_INSTALL='pacman -Syu --noconfirm'
export AURMAN_INSTALL='aurman -Syu --noconfirm --noedit'
export PACMAN_REMOVE_ALL='pacman --noconfirm -Rns'

manual_aur_install() {
    local git_url="${1}"
    local extra_opts="${2}"

    local temp_dir
    temp_dir="$(mktemp -d)"
    git clone "${git_url}" "${temp_dir}"
    pushd "${temp_dir}" || exit
    makepkg --noconfirm -sri ${extra_opts}
    popd || exit
    rm -rf "${temp_dir}"
}
