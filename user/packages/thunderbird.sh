#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} thunderbird xdg-desktop-portal-gnome
if ! grep -q "MOZ_ENABLE_WAYLAND" "${HOME}/.bash_profile"; then
    cat >> "${HOME}/.bash_profile" <<EOL
if [[ "\$XDG_SESSION_TYPE" == "wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
fi
EOL
fi
