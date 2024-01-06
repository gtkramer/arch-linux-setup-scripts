#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

# Video capabilities
${PACMAN_INSTALL} xorg-server xorg-xeyes
if lspci | grep -iq nvidia; then
    ${PACMAN_INSTALL} nvidia nvidia-utils
    systemctl enable nvidia-{hibernate,suspend,resume}
    cat >> /etc/modprobe.d/nvidia.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia-drm modeset=1
options nvidia-drm fbdev=1
EOF
else
    ${PACMAN_INSTALL} mesa mesa-utils
fi

# Audio capabilities
${PACMAN_INSTALL} pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber

# Desktop environment
${PACMAN_INSTALL} gnome gnome-tweaks gnome-firmware
${PACMAN_REMOVE_ALL} gnome-software

# Display manager
${PACMAN_INSTALL} gdm
systemctl enable gdm
sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm/custom.conf
