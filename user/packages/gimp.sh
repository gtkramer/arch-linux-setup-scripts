#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

manual_aur_install https://aur.archlinux.org/gimp-git.git --nocheck
