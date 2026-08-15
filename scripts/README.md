# Scripts

Helper scripts for the lablab stacks.

## Setup

Make the scripts executable once:

```
chmod +x scripts/*.sh
```

All scripts read sensible defaults but accept overrides via environment
variables (for example `BACKUP_ROOT`).

## Index

| Script | Purpose |
| --- | --- |
| `lib.sh` | Shared helpers (colored logging, backups, container checks). Sourced by the others, not run directly. |
| `init-env.sh` | Copy every `stacks/*/.env.example` to `.env` where missing. |
| `backup-volumes.sh` | Archive the important data directories (npm, databases, ftp, immich). |
| `migrate-legacy-stacks.sh` | One-time move from the legacy `/home/arc/stacks` compose layout (npm, dockge, coder + coder-db) onto this repo, without losing data. |

## Typical order for a fresh clone

1. `./scripts/init-env.sh` then edit every new `.env` with real secrets.
2. Create the external networks (`docker network create core-data` and
   `docker network create monitoring-net`, see `../docs/networking.md`).
3. Start the stacks in Dockge.

If you are moving off the legacy `/home/arc/stacks` layout instead of
starting fresh, run `./scripts/migrate-legacy-stacks.sh` after step 2 and
before step 3 for `npm`, `dockge`, and `coder`; see `../docs/migration.md`
for what it does.

## Backups

By default backups are written under `BACKUP_ROOT`, which defaults to
`backups/` in this repo. That is fine for protecting against accidental
deletion, but it is on the same disk as the data it is backing up, so a
disk failure takes out both. Point `BACKUP_ROOT` at external/USB storage
or a NAS if you have one:

```
BACKUP_ROOT=/mnt/usb-backup ./scripts/backup-volumes.sh
```

`ensure_backup_dir` warns and asks for confirmation if the backup target is
on the same disk as `/`, so a backup does not silently give you a false
sense of safety.

- `./scripts/backup-volumes.sh [output_dir]` archives `stacks/npm/data`,
  `stacks/npm/letsencrypt`, `stacks/databases/data`, `stacks/ftp/data`, and
  `stacks/immich/data` to `$BACKUP_ROOT/volumes-<timestamp>/`.
- Stops are not required, but for a fully consistent backup of a stack's
  database (`databases`, `immich`), stop that stack in Dockge first so
  files are not being written mid-archive.
