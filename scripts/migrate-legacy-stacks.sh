#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

LEGACY_ROOT="${LEGACY_ROOT:-/home/arc/stacks}"

log "migrating legacy stacks from $LEGACY_ROOT into $REPO_ROOT/stacks"
warn "this stops the legacy containers it migrates, but never deletes the"
warn "legacy data or removes any container; clean that up by hand once you"
warn "have verified the new stacks work"

migrate_bind() {
  local name="$1" src="$2" dest="$3"

  if [ ! -e "$src" ]; then
    warn "skipping $name: $src not found"
    return
  fi

  if container_running "$name"; then
    confirm "Stop legacy container '$name' before copying its data?" \
      || die "aborted: cannot safely copy data out from under a running container"
    docker stop "$name" >/dev/null
    ok "stopped $name"
  fi

  mkdir -p "$(dirname "$dest")"
  log "copying $src -> $dest"
  rsync -a "$src/" "$dest/"
  ok "copied $name data"
}

log "== npm =="
migrate_bind "nginx-proxy-manager" "$LEGACY_ROOT/npm/data" "$REPO_ROOT/stacks/npm/data"
migrate_bind "nginx-proxy-manager" "$LEGACY_ROOT/npm/letsencrypt" "$REPO_ROOT/stacks/npm/letsencrypt"

log "== dockge =="
migrate_bind "dockge" "$LEGACY_ROOT/dockge/data" "$REPO_ROOT/stacks/dockge/data"

log "== coder =="
warn "coder used to run its own postgres (coder-db); the new coder stack"
warn "uses the shared core-postgres instead, so this dumps coder-db and"
warn "restores it into core-postgres's 'coder' database"

need_cmd docker
require_container "core-postgres"
require_container "coder-db"

if ! docker network inspect core-data >/dev/null 2>&1; then
  log "creating missing core-data network"
  docker network create core-data
fi

: "${CODER_DB_PASSWORD:?set CODER_DB_PASSWORD to the value in stacks/coder/.env before running this}"

role_exists="$(docker exec core-postgres psql -tAc \
  "SELECT 1 FROM pg_roles WHERE rolname = 'coder'" -U postgres || true)"
if [ "$role_exists" != "1" ]; then
  log "creating coder role/database on core-postgres"
  docker exec core-postgres psql -v ON_ERROR_STOP=1 -U postgres -d postgres \
    -c "CREATE ROLE coder LOGIN PASSWORD '$CODER_DB_PASSWORD';"
  docker exec core-postgres createdb -U postgres --owner coder coder
else
  ok "coder role already exists on core-postgres"
fi

ensure_backup_dir "$BACKUP_ROOT"
dump_file="$BACKUP_ROOT/coder-db-migration-$(date +%Y%m%d-%H%M%S).sql"
log "dumping coder-db into $dump_file"
docker exec coder-db pg_dump -U coder -d coder > "$dump_file"
ok "wrote $dump_file ($(du -h "$dump_file" | cut -f1))"

warn "about to restore $dump_file into core-postgres's coder database"
confirm "Proceed with the restore?" || die "aborted: dump is saved at $dump_file, restore later by hand if needed"
docker exec -i core-postgres psql -U coder -d coder < "$dump_file"
ok "restored coder data into core-postgres"

for name in coder coder-db; do
  if container_running "$name"; then
    confirm "Stop legacy container '$name'?" && docker stop "$name" >/dev/null && ok "stopped $name"
  fi
done

ok "migration complete"
log "next steps:"
log "  1. run ./scripts/init-env.sh, then fill in the new .env files"
log "     (stacks/coder/.env's CODER_DB_PASSWORD must match what you used above)"
log "  2. point Dockge's DOCKGE_STACKS_DIR at $REPO_ROOT/stacks (see docs/README.md)"
log "  3. start npm, dockge, and coder from the new location and verify"
log "     each one works before removing anything under $LEGACY_ROOT"
log "  4. once verified, manually remove $LEGACY_ROOT and the old"
log "     coder-db-data volume (docker volume rm coder-db-data)"
