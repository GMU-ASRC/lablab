# lablab

![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%205-c51a4a?logo=raspberrypi&logoColor=white)
![OS](https://img.shields.io/badge/OS-Raspberry%20Pi%20OS-c51a4a?logo=linux&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Managed by](https://img.shields.io/badge/managed%20by-Dockge-5c00d3?logoColor=white)

Configuration-as-code for **MochaNet** — the ARC homelab server.

Each folder under `stacks/` is an independent Dockge stack, same layout as
the main homelab. This checkout is the live Dockge stacks directory on the
server — there is no separate deploy step. See `Docs.md` for the deployment
model.

## Documentation

- [Docs.md](Docs.md) - deployment model, services table, per-stack notes.
- [PORTS.md](PORTS.md) - every published host port and what owns it.
- [scripts/README.md](scripts/README.md) - the helper scripts (env bootstrap).

## Stacks

### Dockge
![Dockge](https://img.shields.io/badge/Dockge-:5001-5c00d3?logo=docker&logoColor=white)

Container management UI. Manages every stack under `stacks/`.

### Glance
![Glance](https://img.shields.io/badge/Glance-:8080-0ea5e9?logo=googlechrome&logoColor=white)

Homelab dashboard — links, service monitor, server stats, Docker status.
Config lives at `stacks/glance/provisioning`.

### Nginx Proxy Manager
![NPM](https://img.shields.io/badge/NPM-:80%20%2F%20:443-F15833?logo=nginx&logoColor=white)

Reverse proxy and SSL termination. Admin UI on `:81`.

### Worker
![Worker](https://img.shields.io/badge/GPU-required-76B900?logo=nvidia&logoColor=white)

Godot eval worker for astro-swarm. No published ports; needs an NVIDIA GPU
host, so it does not run on the Pi itself. Copy
`stacks/worker/.env.example` to `.env` and fill in `API_SECRET_KEY`.

### Grafana
![Grafana](https://img.shields.io/badge/Grafana-:3300-F46800?logo=grafana&logoColor=white)

Dashboards fed by Prometheus. Netbird VPN only, at `grafana.robotics.lab`.
Copy `stacks/grafana/.env.example` to `.env` and fill in admin credentials.

### Prometheus
![Prometheus](https://img.shields.io/badge/Prometheus-:9090-E6522C?logo=prometheus&logoColor=white)

Metrics collector, plus `node-exporter` for host metrics. Netbird VPN only.

### FTP
![FTP](https://img.shields.io/badge/FTPS-:2121-2b8a3e?logo=files&logoColor=white)

FTPS only (plaintext FTP refused). Copy `stacks/ftp/.env.example` to `.env`
and set `FTP_PUBLIC_HOST` to the host's real reachable address.

### Databases
![Postgres](https://img.shields.io/badge/Postgres-core--postgres-336791?logo=postgresql&logoColor=white)
![Valkey](https://img.shields.io/badge/Valkey-core--valkey-DC382D?logo=redis&logoColor=white)

Shared Postgres/Valkey for future stacks to reuse instead of bundling their
own database. No host ports; nothing uses it yet. See `Docs.md` for how to
add a stack to it.

### Gitea Runner
![Runner](https://img.shields.io/badge/act__runner-git.sirblob.co-609926?logo=gitea&logoColor=white)

No local Gitea, just a CI runner that registers against the main homelab's
Gitea at `git.sirblob.co`. Copy `stacks/gitea-runner/.env.example` to
`.env` and paste in a registration token generated on that instance.
