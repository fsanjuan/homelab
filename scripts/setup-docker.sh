#!/bin/bash
# Points the local Docker CLI at the home server, choosing the LAN or Meshnet route.
# Creates/updates the "homelab-lan" and "homelab-meshnet" contexts, probes the LAN host
# on port 22, and selects LAN if reachable, otherwise Meshnet.
#
# Usage: ./scripts/setup-docker.sh [lan|meshnet]   (no argument = auto-detect)
#
# Hosts are read from scripts/docker.env (gitignored; copy docker.env.example) or from
# LAN_HOST / MESHNET_HOST / SERVER_USER env vars.

set -euo pipefail

ENV_FILE="$(dirname "$0")/docker.env"
# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

LAN_HOST="${LAN_HOST:?Set LAN_HOST in scripts/docker.env}"
MESHNET_HOST="${MESHNET_HOST:?Set MESHNET_HOST in scripts/docker.env}"
USER_NAME="${SERVER_USER:-build}"

if [ -n "${DOCKER_HOST:-}" ]; then
  echo "Warning: DOCKER_HOST is set ($DOCKER_HOST) and overrides docker contexts."
  echo "         Remove it from your shell profile (e.g. ~/.zshrc) for this script to take effect."
fi

create_context() {
  local name="$1" host="$2"
  if docker context inspect "$name" >/dev/null 2>&1; then
    docker context update "$name" --docker "host=ssh://$USER_NAME@$host" >/dev/null
  else
    docker context create "$name" --docker "host=ssh://$USER_NAME@$host" >/dev/null
  fi
}

create_context homelab-lan "$LAN_HOST"
create_context homelab-meshnet "$MESHNET_HOST"

choice="${1:-auto}"
if [ "$choice" = "auto" ]; then
  if nc -z -G 2 "$LAN_HOST" 22 >/dev/null 2>&1; then
    choice=lan
  else
    choice=meshnet
  fi
fi

case "$choice" in
  lan|meshnet) ;;
  *) echo "Usage: $0 [lan|meshnet]" >&2; exit 1 ;;
esac

docker context use "homelab-$choice" >/dev/null
echo "Using homelab-$choice"

if docker --context "homelab-$choice" info >/dev/null 2>&1; then
  echo "Connected OK"
else
  echo "Warning: could not reach the Docker daemon via homelab-$choice (check SSH access / Meshnet)" >&2
  exit 1
fi
