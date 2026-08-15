# Port Map

Every host port published across the lablab stacks, what owns it, and the
container port it maps to. Use this to avoid collisions when adding services.

| Host port | Proto | Stack | Service / container | Container port | Notes |
| --- | --- | --- | --- | --- | --- |
| 80 | tcp | npm | nginx-proxy-manager | 80 | Public HTTP |
| 81 | tcp | npm | nginx-proxy-manager | 81 | Admin Web UI |
| 443 | tcp | npm | nginx-proxy-manager | 443 | Public HTTPS |
| 2121 | tcp | ftp | ftp | 21 | FTPS control (TLS enforced) |
| 2283 | tcp | immich | immich_server | 2283 | Immich web/API |
| 3300 | tcp | grafana | grafana | 3000 | Grafana web (Netbird VPN only, grafana.robotics.lab) |
| 5001 | tcp | dockge | dockge | 5001 | Dockge UI |
| 4007 | tcp | postiz | postiz | 5000 | Postiz web (also public via Cloudflare Tunnel) |
| 5173 | tcp | kaneo | kaneo | 5173 | Kaneo web (also public via Cloudflare Tunnel) |
| 7233 | tcp | postiz | temporal | 7233 | Temporal gRPC, loopback only (127.0.0.1), admin/debug access |
| 8005 | tcp | coder | coder | 3000 | Coder web (coder.robotics.lab) |
| 8080 | tcp | glance | glance | 8080 | Glance dashboard |
| 8088 | tcp | postiz | temporal-ui | 8080 | Temporal Web UI, loopback only (127.0.0.1); remapped from upstream's 8080, which collides with glance |
| 9090 | tcp | prometheus | prometheus | 9090 | Prometheus UI/API (Netbird VPN only) |
| 30000-30009 | tcp | ftp | ftp | 30000-30009 | FTP passive port range |

## Host-network services

These use `network_mode: host`, so they bind their ports directly on the
host (no `-p` mapping) and are not in the table above.

| Stack | Service | Key ports | Notes |
| --- | --- | --- | --- |
| prometheus | node-exporter | 9100 | Host metrics; scraped by `prometheus` via `host.docker.internal` |

## Internal-only (no host port)

| Stack | Service / container | Notes |
| --- | --- | --- |
| worker | worker | Outbound only, reports to `SERVER_URL` |
| databases | core-postgres | Port 5432, reachable only on `core-data` |
| databases | core-valkey | Port 6379, reachable only on `core-data` |
| gitea-runner | gitea-runner | Outbound only, registers against git.sirblob.co |
| immich | immich_postgres | Port 5432, default network |
| immich | immich_redis | Port 6379, default network |
| immich | immich_machine_learning | Port 3003, default network |
| kaneo | kaneo-cloudflared | Outbound only, Cloudflare Tunnel to tasks.autonomousrobotics.club |
| postiz | postiz-cloudflared | Outbound only, Cloudflare Tunnel to social.autonomousrobotics.club |
| postiz | temporal-postgresql | Port 5432, internal to `temporal-network`, not on `core-data` |
| postiz | temporal-elasticsearch | Port 9200, internal to `temporal-network`, not on `core-data` |
| postiz | temporal-admin-tools | Interactive CLI only (`docker exec`), no listening port |

## Conflicts and reminders

- New services proxied through NPM only need a single internal/web port;
  route the public hostname in Nginx Proxy Manager rather than publishing
  more ports.
