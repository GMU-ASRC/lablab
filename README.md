# lablab

![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%205-c51a4a?logo=raspberrypi&logoColor=white)
![OS](https://img.shields.io/badge/OS-Raspberry%20Pi%20OS-c51a4a?logo=linux&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Managed by](https://img.shields.io/badge/managed%20by-Dockge-5c00d3?logoColor=white)

Configuration-as-code for **MochaNet** — the ARC homelab server running on a Raspberry Pi 5.

---

## Stacks

### Dockge
![Dockge](https://img.shields.io/badge/Dockge-:5001-5c00d3?logo=docker&logoColor=white)

Container management UI. Stacks stored at `/home/arc/stacks`.

### Glance
![Glance](https://img.shields.io/badge/Glance-:8080-0ea5e9?logo=googlechrome&logoColor=white)

Homelab dashboard — links, service monitor, server stats, Docker status.

### Nginx Proxy Manager
![NPM](https://img.shields.io/badge/NPM-:80%20%2F%20:443-F15833?logo=nginx&logoColor=white)

Reverse proxy and SSL termination. Admin UI on `:81`.

---

> Run `./update.sh` to deploy changes to their live locations.
