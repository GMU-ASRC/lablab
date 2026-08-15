# Maintenance

- Validate any edited stack with `docker compose config` before starting it.
- Run `./scripts/backup-volumes.sh` regularly (npm, databases, ftp, and
  immich data), see `../scripts/README.md`. `stacks/immich/data` in particular
  is not reproducible if lost.
- Back up `stacks/npm/data` and `stacks/npm/letsencrypt` before making proxy
  changes; losing them means reconfiguring every proxy host and cert.
- Back up `stacks/databases/data` before changing anything in that stack,
  once a real app depends on it.
