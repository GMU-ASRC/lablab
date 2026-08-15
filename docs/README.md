# MochaNet Docker Documentation

This documents the organized lablab setup for MochaNet, the ARC homelab server.
Each folder under `stacks/` is an independent
Dockge stack, following the same layout as the main homelab (`docker/`).

## Contents

- [Services](services.md) - every stack, image, ports, and how they fit together.
- [Networking](networking.md) - the `core-data` and `monitoring-net` shared networks.
- [Secrets and .env](secrets.md) - which variables each stack needs, and which must match across stacks.
- [Per-stack notes](stacks/README.md) - deployment details for every stack.
- [Migration](migration.md) - moving off the legacy `/home/arc/stacks` layout.
- [Maintenance](maintenance.md) - backups and validation.

## Related documentation

- `../PORTS.md` - every published host port and what owns it.
- `../scripts/README.md` - the helper scripts (env bootstrap).
- `../docker.md` - enabling NVIDIA GPU support in Docker on this host.

## Host

MochaNet runs on a KVM/QEMU VM (Ubuntu 24.04 x86_64), not a Raspberry Pi,
with an NVIDIA RTX 2080 Ti passed through. `worker` and `immich` both
reserve that GPU; a single card is shared between them (see `../docker.md`),
which only risks contention if a heavy eval run and heavy ML processing
land at the same time.

## Deployment model

This repo is cloned directly onto the host at `/home/arc/lablab`, and that
checkout **is** the live Dockge stacks directory - there is no separate copy
or deploy step. Dockge's own stack points `DOCKGE_STACKS_DIR` at
`/home/arc/lablab/stacks`, and each stack's compose file uses relative binds
(`./data`, `./provisioning`) that resolve inside its own stack folder.

If the repo is cloned to a different path, update the two absolute paths in
`stacks/dockge/docker-compose.yml` (the bind mount and
`DOCKGE_STACKS_DIR`) to match.

To deploy a change: edit the files in this repo on the host (or `git pull`
an update pushed from elsewhere), then use Dockge to restart the affected
stack.
