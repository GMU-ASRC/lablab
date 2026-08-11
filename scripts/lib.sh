#!/usr/bin/env bash

c_red=$'\033[0;31m'
c_yellow=$'\033[0;33m'
c_green=$'\033[0;32m'
c_blue=$'\033[0;34m'
c_reset=$'\033[0m'

BACKUP_ROOT="${BACKUP_ROOT:-$SCRIPT_DIR/../backups}"

log() { printf '%s[*]%s %s\n' "$c_blue" "$c_reset" "$*"; }
ok() { printf '%s[+]%s %s\n' "$c_green" "$c_reset" "$*"; }
warn() { printf '%s[!]%s %s\n' "$c_yellow" "$c_reset" "$*" >&2; }
err() { printf '%s[x]%s %s\n' "$c_red" "$c_reset" "$*" >&2; }
die() { err "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

confirm() {
  local prompt="${1:-Continue?}"
  read -r -p "$prompt [y/N] " reply
  case "$reply" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}

container_running() {
  docker ps --format '{{.Names}}' | grep -qx "$1"
}

require_container() {
  container_running "$1" || die "container not running: $1"
}

ensure_backup_dir() {
  local dir="$1"
  mkdir -p "$dir"
  local root_dev br_dev
  root_dev="$(df --output=source / | tail -1)"
  br_dev="$(df --output=source "$dir" 2>/dev/null | tail -1)"
  if [ "$root_dev" = "$br_dev" ]; then
    warn "backup target $dir is on the same disk as the data being backed up"
    warn "if that disk fails, both the data and the backup are lost"
    confirm "Write backups here anyway?" \
      || die "aborted: set BACKUP_ROOT to external/USB storage"
  fi
}
