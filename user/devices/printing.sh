#!/bin/bash
sudo pacman -Syu --noconfirm cups hplip usbutils python-pyqt5
sudo systemctl enable --now cups.socket
hp-setup
