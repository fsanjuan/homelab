# Home Server Ansible

Ansible project to configure a Ubuntu home server accessible via NordVPN Meshnet.

## What it configures

- **SSH** — ensures the SSH server is enabled and starts on boot
- **NordVPN** — runs in meshnet-only mode (no VPN tunnel), auto-starts on boot
- **Docker** — installs Docker Engine, Compose, and Buildx; adds the `build` user to the docker group
- **Traefik** — reverse proxy with HTTPS via mkcert self-signed certificate; all HTTP redirected to HTTPS
- **Jenkins** — CI server accessible at `https://<meshnet-hostname>/jenkins`, configured via JCasC, with Docker Pipeline support for containerised builds

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

### 1. Generate a TLS certificate with mkcert

```bash
brew install mkcert
mkcert -install
mkcert <your-meshnet-hostname>
mkdir -p certs
mv <your-meshnet-hostname>.pem certs/cert.pem
mv <your-meshnet-hostname>-key.pem certs/key.pem
```

### 2. Configure the inventory

```bash
cp inventory/hosts.yml.example inventory/hosts.yml
```

Fill in your server's meshnet IP and hostname.

### 3. Create the vault file with your Jenkins admin password

```bash
ansible-vault create group_vars/all/vault.yml
```

Content:
```yaml
jenkins_admin_password: your_password_here
```

### 4. Run the playbook

```bash
ansible-playbook site.yml --ask-become-pass --ask-vault-pass
```

## Updating Jenkins plugins

To update all Jenkins plugins to their latest versions and pin them:

```bash
./scripts/update-plugins.sh
```

Then re-run the playbook to rebuild the Jenkins image.
