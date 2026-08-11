#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

created=0
skipped=0

while IFS= read -r example; do
  target="${example%.example}"
  if [ -e "$target" ]; then
    skipped=$((skipped + 1))
    log "exists, skipping: ${target#"$REPO_ROOT"/}"
  else
    cp "$example" "$target"
    created=$((created + 1))
    warn "created ${target#"$REPO_ROOT"/} - edit it and set real secrets"
  fi
done < <(find "$REPO_ROOT/stacks" -name '.env.example' | sort)

ok "env bootstrap done: $created created, $skipped already present"
