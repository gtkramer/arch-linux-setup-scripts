#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${0}")")"
source "${SCRIPT_DIR}/../parameters.sh"

## APPLY FIREWALL RULES
# Remove existing rules
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

# Set default actions
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow local-only connections
iptables -A INPUT -i lo -j ACCEPT

# Permit already established connections and permit new connections related to established ones
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Free output on any interface to any IP for any service
iptables -A OUTPUT -j ACCEPT

# Persist firewall changes
iptables-save > /etc/iptables/iptables.rules
systemctl enable iptables
