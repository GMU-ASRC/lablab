# coder

Migrated off its own bundled `coder-db` (`postgres:15`) onto
the shared `core-postgres`, same as the main homelab's `coder` stack;
`CODER_DB_PASSWORD` must match `databases/.env`. `scripts/migrate-legacy-stacks.sh`
handles the actual data move (dumps the old `coder-db`, restores into
`core-postgres`'s `coder` database), see that script and
[Migration](../migration.md) for what it does. `group_add: ["984"]` gives
the container the host's `docker` group GID for the docker socket mount,
that GID is host-specific (`getent group docker` to check it still
matches after any OS reinstall). `GITHUB_CLIENT_ID`/`GITHUB_CLIENT_SECRET`
come from a GitHub OAuth App (callback URL
`http://coder.robotics.lab/api/v2/users/oauth2/github/callback`).
`CODER_ACCESS_URL=http://coder.robotics.lab` matches the hostname
`glance` already links to. No GPU reservation here, unlike the main
homelab's `coder` stack; add `deploy.resources.reservations.devices` if
workspaces need the RTX 2080 Ti later.
