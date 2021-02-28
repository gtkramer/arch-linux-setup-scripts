#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cp -f "$SCRIPT_DIR/99-kernel.conf" /etc/sysctl.d
