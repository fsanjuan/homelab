# Role: nordvpn

Configures NordVPN to run in meshnet-only mode on boot — no VPN tunnel.

## What it does

- Enables the `nordvpnd` daemon so it starts automatically after a reboot
- Disconnects the VPN tunnel if it is currently active
- Disables VPN auto-connect so the tunnel never starts on boot
- Enables meshnet if it is not already on
