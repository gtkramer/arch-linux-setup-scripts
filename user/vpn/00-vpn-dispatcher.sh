#!/bin/bash

IFACE="$1"
ACTION="$2"

if [[ -n "$IFACE" && "$IFACE" != proton* ]]; then
	if [[ "$ACTION" == "up" ]] && ! pgrep openvpn; then
		protonvpn connect --fastest
	elif [[ "$ACTION" == "pre-down" ]] && pgrep openvpn; then
		protonvpn disconnect
	fi
fi
