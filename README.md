# bluetooth-autoconnect

Systemd service that connects a specific Bluetooth device (e.g. a keyboard) at
boot.

On start it: ensures `bluetooth.service` is running, verifies the configured
controller is present, powers it on, and connects to the configured device.
If any step fails, `bluetooth.service` is stopped again.

## Requirements

- `bluez` (`bluetoothctl`)
- The target device must already be paired

## Installation

```
sudo make install
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```

The service is triggered automatically by a udev rule when the Bluetooth controller
appears — no `systemctl enable` needed.

> [!TIP]
> To see which files will be installed to which locations, run `make`
>
> (This does nothing except print the options)

## Configuration

Edit `/etc/default/bluetooth-autoconnect`:

```sh
# Required
CONTROLLER_ID=AA:BB:CC:DD:EE:FF   # MAC of the Bluetooth adapter
DEVICE_ID=11:22:33:44:55:66       # MAC of the device to connect

# Optional
CONNECT_RETRIES=5                  # attempts before giving up (default: 5)
CONNECT_RETRY_DELAY=2              # seconds between attempts (default: 2)
```

To find your controller and device MACs:

```
bluetoothctl list          # controllers
bluetoothctl devices       # paired devices
```

## Usage

The service starts automatically at boot (via the installed udev rule) whenever
the Bluetooth controller is detected.

To run it manually:

```
sudo systemctl start bluetooth-autoconnect.service
```

Check the result:

```
systemctl status bluetooth-autoconnect.service
bluetoothctl info <DEVICE_ID>
```

## Uninstall

```
sudo make uninstall
sudo udevadm control --reload-rules
```

## Troubleshooting

This will continuously display the log from the service when it runs.

```bash
journalctl -fu bluetooth-autoconnect.service
```
