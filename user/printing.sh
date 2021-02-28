#!/bin/bash
sudo pacman -Sy --noconfirm cups hplip python-pyqt5
sudo systemctl enable --now org.cups.cupsd
hp-setup
