#!/bin/bash
sudo pacman -Sy --noconfirm gcc gdb cmake ninja

INSTALL_DIR="$HOME/.vcpkg"
if [ ! -e "$INSTALL_DIR/.git" ]; then
    rm -rf "$INSTALL_DIR"
    git clone https://github.com/microsoft/vcpkg.git "$INSTALL_DIR"
fi

pushd "$INSTALL_DIR" > /dev/null
git checkout master
git pull
GIT_TAG="$(git describe --tags --abbrev=0)"
git branch -D "$GIT_TAG"
git checkout -b "$GIT_TAG" "$GIT_TAG"
popd > /dev/null

"$HOME/.vcpkg/bootstrap-vcpkg.sh" --useSystemBinaries

if ! type vcpkg; then
    echo 'export PATH="$HOME/.vcpkg:$PATH"' >> "$HOME/.bash_profile"
    "$HOME/.vcpkg/vcpkg" integrate install
fi
