# Port Map

Every host port published across the lablab stacks, what owns it, and the
container port it maps to. Use this to avoid collisions when adding services.

| Host port | Proto | Stack | Service / container | Container port | Notes |
| --- | --- | --- | --- | --- | --- |
| 80 | tcp | npm | nginx-proxy-manager | 80 | Public HTTP |
| 81 | tcp | npm | nginx-proxy-manager | 81 | Admin Web UI |
| 443 | tcp | npm | nginx-proxy-manager | 443 | Public HTTPS |
| 5001 | tcp | dockge | dockge | 5001 | Dockge UI |
| 8080 | tcp | glance | glance | 8080 | Glance dashboard |

## Internal-only (no host port)

| Stack | Service / container | Notes |
| --- | --- | --- |
| worker | worker | Outbound only, reports to `SERVER_URL` |

## Conflicts and reminders

- New services proxied through NPM only need a single internal/web port;
  route the public hostname in Nginx Proxy Manager rather than publishing
  more ports.
