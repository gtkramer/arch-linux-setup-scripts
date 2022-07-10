#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

sudo ${PACMAN_INSTALL} git
TEMP_DIR="$(mktemp -d)"
git clone https://aur.archlinux.org/aurman.git "$TEMP_DIR"
pushd "$TEMP_DIR"
gpg --recv-keys 465022E743D71E39
makepkg -sri
popd
rm -rf "$TEMP_DIR"

# Configure mirrors
sudo ${PACMAN_INSTALL} reflector
sudo reflector --country "$COUNTRY_MIRROR" --sort rate --protocol https --save /etc/pacman.d/mirrorlist

sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/mirrorupgrade.hook > /dev/null <<- EOF
[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating pacman-mirrorlist with reflector...
When = PostTransaction
Depends = reflector
Exec = /usr/bin/reflector --country "$COUNTRY_MIRROR" --sort rate --protocol https --save /etc/pacman.d/mirrorlist
EOF
