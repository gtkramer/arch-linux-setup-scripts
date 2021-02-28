#!/bin/bash
sed -i '/^PS1/d' "$HOME/.bashrc"
sudo sed -i '/^PS1/d' /etc/bash.bashrc
echo 'PS1="\[\033[38;5;33m\][\u@\h:\w] (\$?)\[$(tput sgr0)\]\n\[\033[38;5;172m\]\\$\[$(tput sgr0)\] "' | sudo tee -a /etc/bash.bashrc > /dev/null

if ! grep -Pq '^source /etc/profile.d/vte.sh$' /etc/bash.bashrc; then
	echo 'source /etc/profile.d/vte.sh' | sudo tee -a /etc/bash.bashrc > /dev/null
fi
