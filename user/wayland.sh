#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo ${PACMAN_INSTALL} plasma-wayland-session
echo 'export MOZ_ENABLE_WAYLAND=1' >> "${HOME}/.bash_profile"
echo '--ozone-platform-hint=auto' >> "${XDG_CONFIG_HOME}/code-flags.conf"
