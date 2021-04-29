#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cp -f "$SCRIPT_DIR/30-touchpad.conf" /etc/X11/xorg.conf.d
