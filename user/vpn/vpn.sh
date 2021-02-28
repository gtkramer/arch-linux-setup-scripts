#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

sudo pacman -Sy --noconfirm openvpn dialog python-pip python-setuptools
yes | sudo pip3 install protonvpn-cli

sudo cp -f "$SCRIPT_DIR"/00-vpn-dispatcher.sh /etc/NetworkManager/dispatcher.d
sudo chmod 755 /etc/NetworkManager/dispatcher.d/00-vpn-dispatcher.sh
sudo ln -sf ../00-vpn-dispatcher.sh /etc/NetworkManager/dispatcher.d/pre-down.d/00-vpn-dispatcher.sh

INSTALL_DIR="$HOME/.config/systemd/user"
mkdir -p "$INSTALL_DIR"
cp -f "$SCRIPT_DIR/vpn-notifier.service" "$SCRIPT_DIR/vpn-notifier.timer" "$INSTALL_DIR"
sudo systemctl daemon-reload
systemctl --user enable --now vpn-notifier.timer
