#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../common.sh"

pacman_install vim

cat > "${HOME}/.vimrc" <<'EOF'
set spell
filetype plugin on
syntax on
EOF
