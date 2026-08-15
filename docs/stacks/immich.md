# immich

Deliberately separate from `databases`, same as the main
homelab: its Postgres image (`vectorchord`/`pgvectors`) is required for
its data and cannot be replaced by plain `postgres:16`, and its own
Valkey is bundled rather than shared. Uses the `-cuda` tag of
`immich-machine-learning` plus a `deploy.resources.reservations.devices`
block on both `immich-server` and `immich-machine-learning`, same pattern
as the main homelab, since this host has an NVIDIA GPU (see `../../docker.md`).
`./data/upload` is the photo library, `./data/postgres` is the database,
both bind mounts on the host's own local disk, so the "Postgres must be
on local disk, not a network share" rule from the main homelab is
satisfied automatically here. `model-cache` stays a plain named volume,
it is re-downloadable ML model data, not worth tracking as a bind mount.
`glance` links to it at `immich.robotics.lab`, an NPM proxy host to
`2283` and a Netbird DNS entry for that hostname still need setting up,
see the [glance](glance.md) note.
