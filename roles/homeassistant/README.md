# Role: homeassistant

Runs [Home Assistant Container](https://www.home-assistant.io/installation/linux#docker-compose) plus the [matter.js Matter server](https://github.com/matter-js/matterjs-server), with the YAML configuration kept in git.

## What it does

- Deploys Home Assistant and the Matter server to `/opt/homeassistant`, both with host networking (required for discovery and Matter)
- Serves Home Assistant over HTTPS at `https://<meshnet-hostname>:8123` through a dedicated Traefik entrypoint (Home Assistant can't run under a sub-path like Grafana/Jenkins)
- Templates `configuration.yaml` and `secrets.yaml`, and copies `packages/` and `automations/` from this role
- Validates the configuration with `check_config` before restarting Home Assistant; a broken config fails the run and leaves the running instance alone
- Pins image versions in `defaults/main.yml`

## What lives where

| | Contents | Source of truth |
|---|---|---|
| `configuration.yaml`, `secrets.yaml` | Core YAML config, `!secret` values | **Git** (`templates/`, vault) — overwritten every run |
| `packages/*.yaml` | Feature config: template sensors, helpers, scripts… | **Git** (`files/config/packages/`) |
| `automations/*.yaml` | Automations you want reviewed and versioned | **Git** (`files/config/automations/`) |
| `automations.yaml`, `scripts.yaml`, `scenes.yaml` | Whatever you build in the UI editors | **Server** — created once, never overwritten; covered by backups |
| `.storage/` | Integrations, devices, entities, areas, users, dashboards, location/time zone | **Server** — covered by backups |
| `home-assistant_v2.db` | History | **Server** — covered by backups |
| `/opt/homeassistant/matter` | Matter fabric credentials | **Server** — **not** in Home Assistant backups, see below |

Rule of thumb: git describes *how* Home Assistant is configured; backups hold *what it has learned*. Anything set up through the UI cannot be expressed as code and is only recoverable from a backup.

Removing a file from `files/config/` does not delete it on the server; delete it there too.

## Secrets

Add values to the vault and reference them as `!secret <key>` in YAML:

```yaml
# ansible-vault edit group_vars/all/vault.yml
homeassistant_secrets:
  some_api_key: xxxxx
```

## First-time setup

1. Run the playbook, then open `https://<meshnet-hostname>:8123` and create the owner account. Set location, time zone and units during onboarding (they are stored in `.storage/`, not in git).
2. **Matter:** Settings → Devices & services → Add integration → *Matter*. Uncheck the add-on option and enter `ws://127.0.0.1:5580/ws`.
3. Commission Matter devices with the Home Assistant mobile app (Container installs can't commission directly). For devices already paired with another ecosystem (e.g. Alexa, Google Home, Apple Home), use multi-admin: in that ecosystem's app open the device, choose to share it with another app/controller to get a pairing code, then in the Home Assistant app go to Settings → Devices → Add device → Matter and enter the code. The device keeps working in both.
4. Cloud-based integrations (e.g. Tuya, Hive) are added through the UI under Settings → Devices & services; their credentials live in `.storage/`.

### Matter over Thread

Thread devices are reached through a Thread border router (many smart speakers and hubs are one). The server must accept IPv6 router advertisements with route information for that to work. Check on the server:

```bash
ip -6 route | grep -v '^fe80'      # Thread prefixes should appear "via fe80::..." routes
sysctl net.ipv6.conf.all.forwarding  # should be 0
```

If Thread devices are unreachable, see the [Matter server OS requirements](https://github.com/matter-js/matterjs-server/blob/main/docs/os_requirements.md). On Ubuntu Server the interface is managed by netplan/systemd-networkd, so changes belong in netplan rather than `sysctl -w`.

## Backups

Configure in the UI: Settings → System → Backups.

- Enable **automatic backups** (daily) with a retention count.
- **Save the encryption key** shown there (password manager or the vault). Backups cannot be restored without it.
- Backups are written to `/opt/homeassistant/config/backups/`. Add an off-site location in the same screen (backup-capable integrations such as Home Assistant Cloud, Google Drive, OneDrive or S3) and/or pull them to your laptop:

  ```bash
  ./scripts/pull-ha-backups.sh         # into ./backups/homeassistant/ (gitignored)
  ```

- Back up the Matter server data as well: `/opt/homeassistant/matter` holds the fabric credentials and is not part of Home Assistant backups. Without it, Matter devices have to be re-shared.

**Never commit backups or `.storage/`** — they contain access tokens and personal data.

### Restoring onto a fresh server

1. Run the playbook (creates the containers and the git-managed YAML).
2. On the onboarding screen choose **Restore from backup**, upload the backup and enter the encryption key.
3. Restore `/opt/homeassistant/matter` if you have a copy (stop `matter-server` first).
4. Run the playbook again so the YAML matches git (the restore brings back the YAML as it was when the backup was taken).

## Upgrading

Bump `homeassistant_version` / `matter_server_version` in `defaults/main.yml`, read the release notes for breaking changes, take a backup, then re-run the playbook.
