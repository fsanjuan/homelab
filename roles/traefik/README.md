# Role: traefik

Runs Traefik as a reverse proxy for all Docker services, routing by path.

## What it does

- Creates a shared `proxy` Docker network used by all proxied services
- Deploys Traefik v3.0 listening on port 80
- Auto-discovers containers via Docker labels
- Routes requests to the correct service based on hostname and path

## Adding a new service

Add these labels to the service's `docker-compose.yml`:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<name>.rule=Host(`{{ meshnet_hostname }}`) && PathPrefix(`/<path>`)"
  - "traefik.http.services.<name>.loadbalancer.server.port=<internal-port>"
networks:
  - proxy

networks:
  proxy:
    external: true
```

## Notes

- Traefik must be running before any service that depends on it
- The `proxy` network must exist before other services start — this role creates it
- `meshnet_hostname` is defined in `inventory/hosts.yml`
