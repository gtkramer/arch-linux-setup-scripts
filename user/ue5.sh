#!/usr/bin/env bash
set -ex

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../parameters.sh"

BUILD_DIR="${HOME}/Applications/UnrealEngine"
if [[ ! -e "${BUILD_DIR}/.git" ]]; then
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    git clone --depth 1 --branch release git@github.com:EpicGames/UnrealEngine.git "${BUILD_DIR}"
else
    pushd "${BUILD_DIR}"
    git reset --hard origin/release
    git clean -dxf
    git pull
    popd
fi

cd "${BUILD_DIR}"
./Setup.sh
./GenerateProjectFiles.sh
make
