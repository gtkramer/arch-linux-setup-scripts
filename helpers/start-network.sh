#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/../parameters.sh"

display_help() {
	local script_name
	script_name="$(basename "$0")"
	echo "Usage: $script_name -i <interface> [-s <ssid> -p <password>]"
}

while getopts 'i:s:p:h' OPT; do
	case "$OPT" in
		i)
			IFACE="$OPTARG"
			;;
		s)
			SSID="$OPTARG"
			;;
		p)
			PASSWORD="$OPTARG"
			;;
		h)
			display_help
			exit 0
			;;
		*)
			echo 'Unrecognized option!' >&2
			display_help
			exit 1
			;;
	esac
done

if [ -z "$IFACE" ]; then
	echo 'Parameter -i is required!' >&2
	display_help
	exit 1
fi

if [[ -n "$SSID" && -z "$PASSWORD" ]] || [[ -z "$SSID" && -n "$PASSWORD" ]]; then
	echo 'Both parameters -s and -p are requried!' >&2
	display_help
	exit 1
fi

# Connect to network
ip link set "$IFACE" up
if [ -n "$SSID" ] && [ -n "$PASSWORD" ]; then
	wpa_supplicant -B -i "$IFACE" -c <(wpa_passphrase "$SSID" "$PASSWORD")
fi
systemctl start dhcpcd@"$IFACE"

# Update system clock
timedatectl set-ntp true

# Configure mirrors
pacman -Sy --noconfirm reflector
reflector --country "$COUNTRY_MIRROR" --sort rate --protocol https --save /etc/pacman.d/mirrorlist
