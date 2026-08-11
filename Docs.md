# MochaNet Docker Documentation

This documents the organized lablab setup for MochaNet, the ARC homelab server.
Each folder under `stacks/` is an independent 
Dockge stack, following the same layout as the main homelab (`docker/`).

## Related documentation

- `PORTS.md` - every published host port and what owns it.

## Deployment model

This repo is cloned directly onto the Pi at `/home/arc/lablab`, and that
checkout **is** the live Dockge stacks directory - there is no separate copy
or deploy step. Dockge's own stack points `DOCKGE_STACKS_DIR` at
`/home/arc/lablab/stacks`, and each stack's compose file uses relative binds
(`./data`, `./provisioning`) that resolve inside its own stack folder.

If the repo is cloned to a different path on the Pi, update the two absolute
paths in `stacks/dockge/docker-compose.yml` (the bind mount and
`DOCKGE_STACKS_DIR`) to match.

To deploy a change: edit the files in this repo on the Pi (or `git pull` an
update pushed from elsewhere), then use Dockge to restart the affected stack.

## Services

| Stack | Service / container | Image | Host ports | Data path | Notes |
| --- | --- | --- | --- | --- | --- |
| dockge | dockge | louislam/dockge:latest | 5001 | `./data` | Manages all stacks under `stacks/` |
| glance | glance | glanceapp/glance:latest | 8080 | `./provisioning` | Dashboard config is hand-authored, tracked in git |
| npm | nginx-proxy-manager | jc21/nginx-proxy-manager:latest | 80, 443, 81 | `./data`, `./letsencrypt` | Reverse proxy and SSL termination |

None of these services need a database, so there is no shared datastore stack
here (unlike the main homelab's `core-postgres`/`core-valkey`).

## Per-stack notes

- **dockge:** Mounts the whole repo checkout (`/home/arc/lablab`) into the
  container at the same absolute path, plus the docker socket, so it can
  read and manage every stack's compose file by host path.
- **glance:** `provisioning/` holds the actual dashboard config
  (`glance.yml`, `pages/`) and is tracked in git, the same way the main
  homelab tracks Grafana's `provisioning/` folder. It mounts to `/app/config`
  inside the container. Also gets the docker socket (read-only) so the
  `docker-containers` widget can show container status, and the host
  timezone files so the clock widget matches the Pi.
- **npm:** `./data` and `./letsencrypt` hold NPM's own database and
  certificates. Both are runtime state, not config-as-code, so they are
  gitignored. Admin UI is on port `81`; ports `80`/`443` are the public
  reverse proxy.

## Maintenance

- Validate any edited stack with `docker compose config` before starting it.
- Back up `stacks/npm/data` and `stacks/npm/letsencrypt` before making proxy
  changes; losing them means reconfiguring every proxy host and cert.
