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
| worker | worker | ghcr.io/gmu-asrc/astro-swarm-web-worker:latest | none | `./data` | Godot eval worker, needs an NVIDIA GPU host |
| grafana | grafana | grafana/grafana:latest | 3300 | `./data`, `./provisioning` | Dashboards, Netbird VPN only |
| prometheus | prometheus, node-exporter | prom/prometheus:latest, prom/node-exporter:latest | 9090, host (9100) | `./data` | Metrics feeding grafana, Netbird VPN only |

None of these services need a database, so there is no shared datastore stack
here (unlike the main homelab's `core-postgres`/`core-valkey`).

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

`worker` and `grafana` need secrets. Each has an `.env.example` template;
copy it to `.env` and fill in real values (`API_SECRET_KEY` for worker,
`GRAFANA_ADMIN_USER`/`GRAFANA_ADMIN_PASSWORD` for grafana). `.env` files are
gitignored.

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

## Maintenance

- Validate any edited stack with `docker compose config` before starting it.
- Back up `stacks/npm/data` and `stacks/npm/letsencrypt` before making proxy
  changes; losing them means reconfiguring every proxy host and cert.
