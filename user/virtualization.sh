#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

sudo ${PACMAN_INSTALL} virtualbox virtualbox-host-modules-arch virtualbox-guest-iso
