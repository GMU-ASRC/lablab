# Port Map

Every host port published across the lablab stacks, what owns it, and the
container port it maps to. Use this to avoid collisions when adding services.

| Host port | Proto | Stack | Service / container | Container port | Notes |
| --- | --- | --- | --- | --- | --- |
| 80 | tcp | npm | nginx-proxy-manager | 80 | Public HTTP |
| 81 | tcp | npm | nginx-proxy-manager | 81 | Admin Web UI |
| 443 | tcp | npm | nginx-proxy-manager | 443 | Public HTTPS |
| 2121 | tcp | ftp | ftp | 21 | FTPS control (TLS enforced) |
| 3300 | tcp | grafana | grafana | 3000 | Grafana web (Netbird VPN only, grafana.robotics.lab) |
| 5001 | tcp | dockge | dockge | 5001 | Dockge UI |
| 8080 | tcp | glance | glance | 8080 | Glance dashboard |
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

## Conflicts and reminders

- New services proxied through NPM only need a single internal/web port;
  route the public hostname in Nginx Proxy Manager rather than publishing
  more ports.
