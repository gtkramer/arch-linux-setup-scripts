#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/../../parameters.sh"
sudo pacman -Sy --noconfirm git openssh "$GIT_EDITOR"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global core.editor "$GIT_EDITOR"
git config --global pull.rebase true
git config --global init.defaultBranch main
