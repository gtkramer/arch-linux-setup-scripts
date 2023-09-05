#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
. "${SCRIPT_DIR}/../../parameters.sh"

INSTALL_DIR="${HOME}/.dotnet"
rm -rf "${INSTALL_DIR}"

TEMP_DIR="$(mktemp -d)"
pushd "${TEMP_DIR}"
curl -LO https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --install-dir "${INSTALL_DIR}" -channel STS
./dotnet-install.sh --install-dir "${INSTALL_DIR}" -channel LTS
popd
rm -rf "${TEMP_DIR}"

if ! grep -q dotnet "${HOME}/.bashrc"; then
	echo "export PATH=\"${INSTALL_DIR}:\${PATH}\"" >> "${HOME}/.bashrc"
fi
