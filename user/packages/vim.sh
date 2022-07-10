#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

sudo ${PACMAN_INSTALL} vim
if ! grep -Pq '^set spell$' /etc/vimrc; then
	echo 'set spell' | sudo tee -a /etc/vimrc > /dev/null
fi
sed -i '/^export VISUAL/d' "${HOME}/.bashrc"
sudo sed -i '/^export VISUAL/d' /etc/bash.bashrc
echo "export VISUAL=vim" | sudo tee -a /etc/bash.bashrc > /dev/null
