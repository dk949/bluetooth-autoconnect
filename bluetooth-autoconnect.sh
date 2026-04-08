#!/bin/bash
set -euo pipefail

: "${CONTROLLER_ID:?CONTROLLER_ID not set in /etc/default/bluetooth-autoconnect}"
: "${DEVICE_ID:?DEVICE_ID not set in /etc/default/bluetooth-autoconnect}"
: "${CONNECT_RETRIES:=5}"
: "${CONNECT_RETRY_DELAY:=2}"

# Verify the controller is present
if ! bluetoothctl show "$CONTROLLER_ID" > /dev/null 2>&1; then
    echo "Controller $CONTROLLER_ID not found" >&2
    exit 1
fi

# Select the controller and power it on
bluetoothctl << EOF
select $CONTROLLER_ID
power on
EOF

# Connect with retries.
# bluetoothctl's exit code for 'connect' is unreliable, so we verify the link
# by polling 'bluetoothctl info' for 'Connected: yes' after each attempt.
for i in $(seq 1 "$CONNECT_RETRIES"); do
    echo "Connect attempt $i/$CONNECT_RETRIES..."
    bluetoothctl << EOF || true
select $CONTROLLER_ID
connect $DEVICE_ID
EOF
    if bluetoothctl info "$DEVICE_ID" 2>/dev/null | grep -q "Connected: yes"; then
        echo "Connected to $DEVICE_ID"
        exit 0
    fi
    sleep "$CONNECT_RETRY_DELAY"
done

echo "Failed to connect to $DEVICE_ID after $CONNECT_RETRIES attempts" >&2
exit 1
