# Home Server Ansible

Ansible project to configure a Ubuntu home server accessible via NordVPN Meshnet.

## What it configures

- **SSH** — ensures the SSH server is enabled and starts on boot
- **NordVPN** — runs in meshnet-only mode (no VPN tunnel), auto-starts on boot
- **Docker** — installs Docker Engine, Compose, and Buildx; adds the `build` user to the docker group

## Prerequisites

### Server

- Ubuntu Server with NordVPN installed and logged in
- A user named `build` with sudo access and SSH key authentication set up
- NordVPN meshnet enabled on the server

### Laptop

- Ansible installed
- NordVPN meshnet enabled and connected
- SSH access to the server as the `build` user

## Setup

1. Copy the inventory template and fill in your server's meshnet IP or hostname:

```bash
cp inventory/hosts.yml.example inventory/hosts.yml
```

2. Run the playbook:

```bash
ansible-playbook site.yml --ask-become-pass
```
