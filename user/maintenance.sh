#!/bin/bash
aurman -Syu --noconfirm --noedit --do_everything
sudo pacman -Rns $(sudo pacman -Qdtq)
sudo pacman -Sc
