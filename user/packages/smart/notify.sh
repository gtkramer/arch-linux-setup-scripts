#!/bin/bash
# Sends a GNOME desktop notification to all logged-in graphical users
# when smartd detects a disk health issue.
# Sourced by /usr/share/smartmontools/smartd_warning.sh with SMARTD_* env vars.
# Uses gdbus (glib2) to call org.freedesktop.Notifications directly.

readonly SUMMARY="Disk Health Warning: ${SMARTD_DEVICESTRING:-unknown}"
readonly BODY="${SMARTD_MESSAGE:-A S.M.A.R.T. error has been detected.}"

while IFS= read -r session_id; do
    [[ -z "${session_id}" ]] && continue

    session_type="$(loginctl show-session "${session_id}" -p Type --value)"
    [[ "${session_type}" == "x11" || "${session_type}" == "wayland" ]] || continue

    uid="$(loginctl show-session "${session_id}" -p User --value)"
    user="$(loginctl show-session "${session_id}" -p Name --value)"

    sudo -u "${user}" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${uid}/bus" \
        gdbus call --session \
            --dest=org.freedesktop.Notifications \
            --object-path=/org/freedesktop/Notifications \
            --method=org.freedesktop.Notifications.Notify \
            'S.M.A.R.T.' 0 'drive-harddisk' \
            "${SUMMARY}" "${BODY}" \
            '[]' '{"urgency": <byte 2>}' -1 \
        > /dev/null 2>&1 || true
done < <(loginctl list-sessions --no-legend | awk '{print $1}')
