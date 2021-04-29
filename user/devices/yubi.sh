#!/bin/bash
sudo pacman -Sy --noconfirm yubioath-desktop
sudo systemctl enable --now pcscd.socket
