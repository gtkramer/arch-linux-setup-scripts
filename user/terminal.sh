#!/bin/bash
# Set a custom bash prompt and inter-command spacing in the user's ~/.bashrc.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

# Drop only our own assignment lines (anchored, so unrelated lines mentioning PS1 are left alone).
sed -i -E '/^(export )?PS1=/d; /^(export )?PROMPT_COMMAND=/d' "${HOME}/.bashrc"

cat >> "${HOME}/.bashrc" <<'EOF'
export PS1='[\u@\h:\w]\n\\$ '
export PROMPT_COMMAND='printf "\n"'
EOF
