#!/bin/bash
set -ex

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

BUILD_DIR="${HOME}/Builds/Epic/UnrealEngine"
if [[ ! -e "${BUILD_DIR}/.git" ]]; then
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    git clone git@github.com:EpicGames/UnrealEngine.git -b release "${BUILD_DIR}"
else
    pushd "${BUILD_DIR}"
    git reset --hard origin/release
    git clean -dxf
    git pull
    git clean -dxf
    popd
fi

export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
sudo ln -sf /etc/ssl /usr/lib/ssl

cd "${BUILD_DIR}"
./Setup.sh
./GenerateProjectFiles.sh
make
