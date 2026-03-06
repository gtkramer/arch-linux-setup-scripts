#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../../common.sh"

pacman_install git "${GIT_EDITOR}"
git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"
git config --global core.editor "${GIT_EDITOR}"
git config --global pull.rebase true
git config --global init.defaultBranch main
