#!/bin/bash
# Orchestrate the post-boot system configuration scripts in order. Run as root.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

require_root

run_scripts "${SCRIPT_DIR}" desktop system firewall bluetooth
