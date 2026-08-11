# MochaNet Docker Documentation

This documents the organized lablab setup for MochaNet, the ARC homelab server.
Each folder under `stacks/` is an independent 
Dockge stack, following the same layout as the main homelab (`docker/`).

## Related documentation

- `PORTS.md` - every published host port and what owns it.
- `scripts/README.md` - the helper scripts (env bootstrap).

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
| worker | worker | ghcr.io/gmu-asrc/astro-swarm-web-worker:latest | none | `./data` | Godot eval worker, needs an NVIDIA GPU host |
| grafana | grafana | grafana/grafana:latest | 3300 | `./data`, `./provisioning` | Dashboards, Netbird VPN only |
| prometheus | prometheus, node-exporter | prom/prometheus:latest, prom/node-exporter:latest | 9090, host (9100) | `./data` | Metrics feeding grafana, Netbird VPN only |
| ftp | ftp | stilliard/pure-ftpd:latest | 2121, 30000-30009 | `./data`, `./config` | FTPS (TLS enforced), single admin user |
| databases | core-postgres, core-valkey | postgres:16, valkey/valkey:8-bookworm | none | `./data` | Shared datastore for future stacks, see below |
| gitea-runner | gitea-runner | gitea/act_runner:latest | none | `./data` | Registers against git.sirblob.co, no local Gitea |
| immich | immich_server, immich_machine_learning, immich_redis, immich_postgres | ghcr.io/immich-app/immich-server, immich-machine-learning, valkey, immich-app/postgres | 2283 | `./data` | Photo library, CPU-only ML (no GPU on the Pi) |

No stack here currently requires a database. `databases` exists so a future
app can reuse a shared Postgres/Valkey instead of bundling its own, the same
model as the main homelab's `core-postgres`/`core-valkey`. `grafana` could
point at it (`GF_DATABASE_*` env vars) instead of its embedded SQLite, but
the main homelab deliberately leaves Grafana on SQLite too (same reasoning
as `archivebox` there: a single lightweight dashboard app gets nothing from
an external database), so lablab's `grafana` stays on SQLite by default as
well.

## The `core-data` network

`databases` and any stack that uses it need to reach each other by
container name, so they share an external network. Create it once on the
host:

```
docker network create core-data
```

Each consuming stack declares it as external:

```yaml
networks:
  core-data:
    external: true
```

Reach the datastores by container name: `core-postgres` and `core-valkey`.
Start the `databases` stack, and wait until `core-postgres` is healthy,
before starting anything that depends on it.

### If a stack needs a database

Attach it to `core-data`, then create a role and database by hand:

```
docker exec -it core-postgres psql -U postgres \
  -c "CREATE ROLE myapp LOGIN PASSWORD 'change_me';" \
  -c "CREATE DATABASE myapp OWNER myapp;"
```

```yaml
services:
  myapp:
    environment:
      - DATABASE_URL=postgresql://myapp:change_me@core-postgres:5432/myapp
    networks:
      - core-data
networks:
  core-data:
    external: true
```

## The `monitoring-net` network

`grafana` and `prometheus` are separate Dockge stacks, so they share an
external network to reach each other by container name. Create it once on
the host:

```
docker network create monitoring-net
```

`grafana` reaches `prometheus` at `http://prometheus:9090` (see the
provisioned datasource in
`stacks/grafana/provisioning/datasources/datasource.yml`). Start
`prometheus` before `grafana` so the datasource can reach it on first load.

## Secrets and `.env`

`worker`, `grafana`, `ftp`, `databases`, `gitea-runner`, and `immich` need
secrets. Each has an `.env.example` template; copy it to `.env` and fill in
real values (`API_SECRET_KEY` for worker, `GRAFANA_ADMIN_USER`/
`GRAFANA_ADMIN_PASSWORD` for grafana, `FTP_PUBLIC_HOST`/`FTP_USER_PASS` for
ftp, `POSTGRES_PASSWORD` for databases, `GITEA_RUNNER_TOKEN` for
gitea-runner, `DB_PASSWORD` for immich). `.env` files are gitignored.

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
- **worker:** Pulls a Godot dedicated-server build and runs simulation
  evals for the `astroswarm.autonomousrobotics.club` server, reporting
  results back over `SERVER_URL`. Reserves one NVIDIA GPU via
  `deploy.resources.reservations.devices`, so this stack cannot run on the
  Pi itself - point Dockge's stacks dir at a GPU-equipped host, or run this
  one manually on that host with the same compose file. `WORKER_MAX_JOBS`
  and `EVAL_SHARD_COUNT` should be tuned per machine.
- **grafana:** Runs as uid/gid `472`, so a one-shot `grafana-init` container
  `chown`s `./data` to `472` before the server starts. `provisioning/` holds
  the datasource config and is tracked in git, the same pattern as
  `glance/provisioning`. Not exposed via NPM; reached only over the Netbird
  VPN at `grafana.robotics.lab` (set in `GF_SERVER_ROOT_URL`) - that
  hostname needs a Netbird DNS entry pointing at this host. To get the
  **Node Exporter Full** dashboard, log in, go to Dashboards -> New ->
  Import, enter ID `1860`, and pick the `Prometheus` datasource.
- **prometheus:** Runs as uid/gid `65534` (`nobody`), so a one-shot
  `prometheus-init` container `chown`s `./data` to `65534` before the
  server starts. Scrapes itself and `node-exporter`
  (`stacks/prometheus/prometheus.yml`). `node-exporter` runs with
  `network_mode: host` and `pid: host` to read real host metrics, and is
  scraped by `prometheus` at `host.docker.internal:9100`
  (`extra_hosts: host.docker.internal:host-gateway` resolves the host from
  inside the container). Not exposed via NPM; Netbird VPN only, same as
  `grafana`.
- **ftp:** Single `stilliard/pure-ftpd` user, TLS enforced (`--tls=2` in
  `ADDED_FLAGS`), so this is FTPS only, plaintext FTP connections are
  refused. The image generates a self-signed cert on first start if none is
  present at `/etc/ssl/private`; `./config/tls` persists it across restarts
  so clients don't see a new cert (and a new trust prompt) every time.
  `FTP_PUBLIC_HOST` must be the host's real reachable IP or hostname, it is
  used both for the passive-mode `PASV` reply and the TLS cert's CN, and
  must match on the client side too since passive mode depends on it.
  Passive ports `30000-30009` must stay open alongside `2121`. `./data` is
  the FTP root, `./config/pureftpd` holds the virtual-user password
  database.
- **databases:** `core-postgres` and `core-valkey`, no host ports; reachable
  only over `core-data`. No stack here uses it yet, see "If a stack needs a
  database" above for how to add one.
- **gitea-runner:** `gitea/act_runner`, no local Gitea, just a runner that
  registers against the main homelab's Gitea at `git.sirblob.co`
  (`GITEA_INSTANCE_URL`). Generate `GITEA_RUNNER_TOKEN` on that instance
  (Site Administration -> Actions -> Runners -> Create new runner, or the
  repo/org-level equivalent) and copy it into `.env`; a registration token
  is single-use, once the runner has registered `./data` holds its
  persistent identity, so it does not need to re-register on restart. Gets
  the docker socket so Actions jobs can run in containers. No `network_mode:
  host` needed here (unlike the main homelab's runner, which reaches its
  Gitea over `localhost`); this one only needs outbound HTTPS to
  `git.sirblob.co`.
- **immich:** Deliberately separate from `databases`, same as the main
  homelab: its Postgres image (`vectorchord`/`pgvectors`) is required for
  its data and cannot be replaced by plain `postgres:16`, and its own
  Valkey is bundled rather than shared. Unlike the main homelab's GPU
  build, this uses the default (CPU) `immich-machine-learning` image with
  no `deploy.resources.reservations.devices` block, since the Pi has no
  NVIDIA GPU; ML tasks (face/object detection) just run slower. `./data/upload`
  is the photo library, `./data/postgres` is the database, both bind mounts
  on the Pi's own disk, so the "Postgres must be on local disk, not a
  network share" rule from the main homelab is satisfied automatically
  here. `model-cache` stays a plain named volume, it is re-downloadable ML
  model data, not worth tracking as a bind mount.

## Maintenance

- Validate any edited stack with `docker compose config` before starting it.
- Run `./scripts/backup-volumes.sh` regularly (npm, databases, ftp, and
  immich data), see `scripts/README.md`. `stacks/immich/data` in particular
  is not reproducible if lost.
- Back up `stacks/npm/data` and `stacks/npm/letsencrypt` before making proxy
  changes; losing them means reconfiguring every proxy host and cert.
- Back up `stacks/databases/data` before changing anything in that stack,
  once a real app depends on it.
