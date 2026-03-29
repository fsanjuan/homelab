# Role: traefik

Runs Traefik as a reverse proxy for all Docker services, with HTTPS via mkcert.

## What it does

- Creates a shared `proxy` Docker network used by all proxied services
- Deploys Traefik v2.11 listening on ports 80 and 443
- Redirects all HTTP traffic to HTTPS automatically
- Serves a mkcert-issued TLS certificate for the meshnet hostname
- Auto-discovers containers via Docker labels

## Prerequisites

Generate a local certificate with mkcert on your laptop before running the playbook:

```bash
brew install mkcert
mkcert -install
mkcert <your-meshnet-hostname>
mkdir -p certs
mv <your-meshnet-hostname>.pem certs/cert.pem
mv <your-meshnet-hostname>-key.pem certs/key.pem
```

The `certs/` directory is gitignored and must exist locally before running the playbook.

## Adding a new service

Add these labels to the service's `docker-compose.yml`:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<name>.rule=Host(`{{ meshnet_hostname }}`) && PathPrefix(`/<path>`)"
  - "traefik.http.routers.<name>.entrypoints=websecure"
  - "traefik.http.routers.<name>.tls=true"
  - "traefik.http.services.<name>.loadbalancer.server.port=<internal-port>"
networks:
  - proxy

networks:
  proxy:
    external: true
```

## Notes

- Traefik must run before any service that depends on it
- `meshnet_hostname` is defined in `inventory/hosts.yml`
- Renew the mkcert certificate yearly by re-running `mkcert` and re-running the playbook
