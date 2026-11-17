#!/bin/bash
# Copies Home Assistant backups from the home server to this machine, so a copy
# survives if the server's disk dies. Backups land in ./backups/homeassistant/
# (gitignored: they contain access tokens and personal data, never commit them).
#
# Usage: ./scripts/pull-ha-backups.sh [lan|meshnet]   (no argument = auto-detect)
#
# Hosts are read from scripts/docker.env, the same file setup-docker.sh uses.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/scripts/docker.env"
# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

LAN_HOST="${LAN_HOST:?Set LAN_HOST in scripts/docker.env}"
MESHNET_HOST="${MESHNET_HOST:?Set MESHNET_HOST in scripts/docker.env}"
USER_NAME="${SERVER_USER:-build}"
REMOTE_DIR=/opt/homeassistant/config/backups/
LOCAL_DIR="$ROOT/backups/homeassistant/"

choice="${1:-auto}"
if [ "$choice" = "auto" ]; then
  if nc -z -G 2 "$LAN_HOST" 22 >/dev/null 2>&1; then choice=lan; else choice=meshnet; fi
fi
case "$choice" in
  lan) host="$LAN_HOST" ;;
  meshnet) host="$MESHNET_HOST" ;;
  *) echo "Usage: $0 [lan|meshnet]" >&2; exit 1 ;;
esac

mkdir -p "$LOCAL_DIR"
chmod 700 "$ROOT/backups"
echo "Pulling backups from $choice host..."
# No --delete: backups pruned on the server by retention are kept here.
rsync -av --chmod=F600 "$USER_NAME@$host:$REMOTE_DIR" "$LOCAL_DIR"
