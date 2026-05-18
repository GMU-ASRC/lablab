#!/usr/bin/env bash
# Deploys config from this repo to live locations.
# Add new service mappings to the SERVICES array as: [subdir]="live_target_dir"

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -A SERVICES=(
  [glance]="/home/arc/stacks/glance/config"
  [dockge]="/home/arc/stacks"
)

for service in "${!SERVICES[@]}"; do
  src="$REPO_DIR/$service"
  dest="${SERVICES[$service]}"

  if [ ! -d "$src" ]; then
    echo "SKIP $service: $src not found in repo"
    continue
  fi

  echo "Deploying $service -> $dest"
  mkdir -p "$dest"
  cp -r "$src/." "$dest/"
done

echo "Done."
