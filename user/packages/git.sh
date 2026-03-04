#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

pacman_install git openssh "${GIT_EDITOR}"
git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"
git config --global core.editor "${GIT_EDITOR}"
git config --global pull.rebase true
git config --global init.defaultBranch main
