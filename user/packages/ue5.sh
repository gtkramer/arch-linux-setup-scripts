#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
readonly SCRIPT_DIR
. "${SCRIPT_DIR}/../../common.sh"

build_dir="${HOME}/Applications/UnrealEngine"
if [[ ! -e "${build_dir}/.git" ]]; then
    rm -rf "${build_dir}"
    mkdir -p "${build_dir}"
    git clone --depth 1 --branch release git@github.com:EpicGames/UnrealEngine.git "${build_dir}"
else
    pushd "${build_dir}"
    git reset --hard origin/release
    git clean -dxf
    git pull
    popd
fi

cd "${build_dir}"
./Setup.sh
./GenerateProjectFiles.sh
make
