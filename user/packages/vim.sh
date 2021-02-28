#!/bin/bash
sudo pacman -Sy --noconfirm vim
if ! grep -Pq '^set spell$' /etc/vimrc; then
	echo 'set spell' | sudo tee -a /etc/vimrc > /dev/null
fi
sed -i '/^export VISUAL/d' "$HOME/.bashrc"
sudo sed -i '/^export VISUAL/d' /etc/bash.bashrc
echo "export VISUAL=vim" | sudo tee -a /etc/bash.bashrc > /dev/null
