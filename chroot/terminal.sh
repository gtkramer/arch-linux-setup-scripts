#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

sed -i '/^PS1/d' "${HOME}/.bashrc"
sed -i '/^PS1/d' /etc/bash.bashrc
echo 'PS1="\[\033[38;5;33m\][\u@\h:\w] (\$?)\[$(tput sgr0)\]\n\[\033[38;5;172m\]\\$\[$(tput sgr0)\] "' | tee -a /etc/bash.bashrc > /dev/null

if ! grep -Pq '^source /etc/profile.d/vte.sh$' /etc/bash.bashrc; then
	echo 'source /etc/profile.d/vte.sh' | tee -a /etc/bash.bashrc > /dev/null
fi
