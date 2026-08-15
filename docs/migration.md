# Migrating off the legacy `/home/arc/stacks` layout

Before this repo, `npm`, `dockge`, and `coder` (with its own `coder-db`)
ran as ad hoc compose files directly under `/home/arc/stacks`, with no
`.env.example`, no shared database, and no git history. Run
`./scripts/migrate-legacy-stacks.sh` once to move onto this repo's layout
without losing data:

- `npm`: stops the legacy `nginx-proxy-manager` container, then copies
  `/home/arc/stacks/npm/data` and `/home/arc/stacks/npm/letsencrypt` into
  `stacks/npm/data` and `stacks/npm/letsencrypt`.
- `dockge`: stops the legacy `dockge` container, then copies
  `/home/arc/stacks/dockge/data` into `stacks/dockge/data`.
- `coder`: requires `core-postgres` (the `databases` stack) already
  running. Creates the `coder` role/database on `core-postgres` if it does
  not exist yet, `pg_dump`s the legacy `coder-db` container to
  `$BACKUP_ROOT/coder-db-migration-<timestamp>.sql` (a safety copy that is
  kept regardless of what happens next), then restores that dump into
  `core-postgres`. Stops the legacy `coder` and `coder-db` containers last.

The script never deletes anything, it only stops legacy containers and
copies data; the legacy `/home/arc/stacks` directory and the old
`coder-db-data` volume are left in place until you have verified the new
stacks work and remove them by hand. `LEGACY_ROOT` (default
`/home/arc/stacks`) and `CODER_DB_PASSWORD` (required, no default) are
read from the environment, so run it as
`CODER_DB_PASSWORD=... ./scripts/migrate-legacy-stacks.sh`.
