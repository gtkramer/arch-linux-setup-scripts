#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
readonly SCRIPT_DIR
. "${SCRIPT_DIR}/../../common.sh"

pacman_install vim

cat > "${HOME}/.vimrc" <<'EOF'
set spell
filetype plugin on
syntax on
EOF
