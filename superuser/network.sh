#!/bin/bash
pacman -Sy --noconfirm networkmanager
systemctl enable NetworkManager
