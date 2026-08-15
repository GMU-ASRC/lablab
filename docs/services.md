# Services

| Stack | Service / container | Image | Host ports | Data path | Notes |
| --- | --- | --- | --- | --- | --- |
| dockge | dockge | louislam/dockge:latest | 5001 | `./data` | Manages all stacks under `stacks/` |
| glance | glance | glanceapp/glance:latest | 8080 | `./provisioning` | Dashboard config is hand-authored, tracked in git |
| npm | nginx-proxy-manager | jc21/nginx-proxy-manager:latest | 80, 443, 81 | `./data`, `./letsencrypt` | Reverse proxy and SSL termination |
| worker | worker | ghcr.io/gmu-asrc/astro-swarm-web-worker:latest | none | `./data` | Godot eval worker, GPU-accelerated (RTX 2080 Ti) |
| grafana | grafana | grafana/grafana:latest | 3300 | `./data`, `./provisioning` | Dashboards, Netbird VPN only |
| prometheus | prometheus, node-exporter | prom/prometheus:latest, prom/node-exporter:latest | 9090, host (9100) | `./data` | Metrics feeding grafana, Netbird VPN only |
| ftp | ftp | stilliard/pure-ftpd:latest | 2121, 30000-30009 | `./data`, `./config` | FTPS (TLS enforced), single admin user |
| databases | core-postgres, core-valkey | postgres:16, valkey/valkey:8-bookworm | none | `./data` | Shared datastore for future stacks, see [Networking](networking.md) |
| gitea-runner | gitea-runner | gitea/act_runner:latest | none | `./data` | Registers against git.sirblob.co, no local Gitea |
| immich | immich_server, immich_machine_learning, immich_redis, immich_postgres | ghcr.io/immich-app/immich-server, immich-machine-learning, valkey, immich-app/postgres | 2283 | `./data` | Photo library, GPU-accelerated ML (RTX 2080 Ti) |
| kaneo | kaneo, kaneo-cloudflared | ghcr.io/usekaneo/kaneo:latest, cloudflare/cloudflared:latest | 5173 | none | Task tracker, uses `core-postgres`, public via Cloudflare Tunnel |
| coder | coder | ghcr.io/coder/coder:latest | 8005 | none | Cloud dev environments, uses `core-postgres`, migrated off its own `coder-db` |
| postiz | postiz, postiz-cloudflared, temporal, temporal-ui, temporal-admin-tools, temporal-postgresql, temporal-elasticsearch | ghcr.io/gitroomhq/postiz-app:latest, cloudflare/cloudflared:latest, temporalio/auto-setup:1.28.1, temporalio/ui:2.34.0, temporalio/admin-tools:1.28.1-tctl-1.18.4-cli-1.4.1, postgres:16, elasticsearch:7.17.27 | 4007, 7233 (loopback), 8088 (loopback) | `./data/temporal-postgres` | Social media scheduler, uses `core-postgres`/`core-valkey` for its own app DB, bundles its own Temporal cluster, public via Cloudflare Tunnel |

`kaneo` is the first stack that actually reuses `databases`: instead of
bundling its own Postgres like the upstream Kaneo docs show, it points
`DATABASE_URL` at `core-postgres` and gets a `kaneo` role/database from
`stacks/databases/init/01-init-databases.sh`. `postiz` does the same for
its own app database and additionally reuses `core-valkey` for its Redis
cache (the first consumer of `core-valkey`); its bundled Temporal cluster
still gets its own dedicated Postgres, since Temporal's `auto-setup` image
needs `CREATEDB` rights to provision its schema, which the shared
`core-postgres` roles deliberately don't have. `grafana` could point at
`databases` too (`GF_DATABASE_*` env vars) instead of its embedded SQLite,
but the main homelab deliberately leaves Grafana on SQLite (same reasoning
as `archivebox` there: a single lightweight dashboard app gets nothing from
an external database), so lablab's `grafana` stays on SQLite by default as
well.

See [Per-stack notes](stacks/README.md) for the deployment details behind
each row.
