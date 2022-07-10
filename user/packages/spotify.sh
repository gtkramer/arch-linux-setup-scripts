#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../../parameters.sh"

curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --import -
${AURMAN_INSTALL} spotify
