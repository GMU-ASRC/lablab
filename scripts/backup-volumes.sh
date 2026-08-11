#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OUT_DIR="${1:-$BACKUP_ROOT/volumes-$(date +%Y%m%d-%H%M%S)}"

PATHS=(
  "$REPO_ROOT/stacks/npm/data"
  "$REPO_ROOT/stacks/npm/letsencrypt"
  "$REPO_ROOT/stacks/databases/data"
  "$REPO_ROOT/stacks/ftp/data"
  "$REPO_ROOT/stacks/immich/data"
)

need_cmd tar
ensure_backup_dir "$OUT_DIR"

warn "this archives large data directories and needs time and free disk space"
confirm "Proceed?" || die "aborted"

for path in "${PATHS[@]}"; do
  if [ ! -e "$path" ]; then
    warn "skipping missing path: $path"
    continue
  fi
  name="$(printf '%s' "${path#"$REPO_ROOT"/}" | sed 's#/#_#g')"
  out="$OUT_DIR/$name.tar.gz"
  log "archiving $path"
  tar -czf "$out" -C "$(dirname "$path")" "$(basename "$path")"
  ok "wrote $out ($(du -h "$out" | cut -f1))"
done

ok "volume backup complete: $OUT_DIR"
