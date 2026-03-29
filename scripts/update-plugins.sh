#!/bin/bash
# Resolves latest versions of all plugins in plugins.txt using a temporary Jenkins container.
# Run this to update plugins, then rebuild the Jenkins image with the playbook.
#
# Usage: ./scripts/update-plugins.sh

set -euo pipefail

PLUGINS_FILE="$(dirname "$0")/../roles/jenkins/files/plugins.txt"
CONTAINER="jenkins-update-temp"

echo "Starting temporary Jenkins container..."
docker run -d --name "$CONTAINER" jenkins/jenkins:lts

echo "Installing plugins..."
docker cp "$PLUGINS_FILE" "$CONTAINER":/tmp/plugins.txt
docker exec "$CONTAINER" jenkins-plugin-cli --plugin-file /tmp/plugins.txt

echo "Snapshotting installed versions..."
docker exec "$CONTAINER" jenkins-plugin-cli --list \
  | awk 'NR>1 && $1 != "" { print $1 ":" $2 }' \
  > "$PLUGINS_FILE"

echo "Cleaning up..."
docker rm -f "$CONTAINER"

echo "plugins.txt updated:"
cat "$PLUGINS_FILE"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff roles/jenkins/files/plugins.txt"
echo "  2. Run the playbook to rebuild the Jenkins image"
