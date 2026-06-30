#!/bin/bash
# Enable multilib and install Steam, launchers, controller support, and gaming overlays.
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR SCRIPT_NAME
. "${SCRIPT_DIR}/../common.sh"

# 32-bit GPU drivers
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    if grep -q '^#\[multilib\]' /etc/pacman.conf; then
        sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    else
        printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' | sudo tee -a /etc/pacman.conf > /dev/null
    fi
fi
pacman_install lib32-nvidia-utils lib32-mesa lib32-vulkan-intel

# Game launchers
pacman_install steam
aur_install heroic-games-launcher-bin

# Xbox controller support
aur_install xpadneo-dkms

# Performance and overlay tooling
pacman_install gamemode lib32-gamemode mangohud lib32-mangohud gamescope
mkdir -p "${HOME}/.config/MangoHud"
cat > "${HOME}/.config/MangoHud/MangoHud.conf" <<'EOF'
position=top-left
horizontal=1
legacy_layout=0
table_columns=28
font_size=32
background_alpha=0.4
text_color=FFFFFF
gpu_color=FFFFFF
cpu_color=FFFFFF
vram_color=FFFFFF
ram_color=FFFFFF
frametime_color=FFFFFF

gpu_stats
vram
cpu_stats
ram
fps
frametime
frame_timing

engine_version=0

no_display=1
toggle_hud=Shift_R+Delete
EOF
