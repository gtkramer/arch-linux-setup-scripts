#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

sed -i '/PS1/d' "${HOME}/.bashrc"
sed -i '/PROMPT_COMMAND/d' "${HOME}/.bashrc"

cat >> "${HOME}/.bashrc" <<'EOF'
export PS1='[\u@\h:\w]\n\\$ '
export PROMPT_COMMAND='printf "\n"'
EOF
