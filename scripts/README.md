# Scripts

Helper scripts for the lablab stacks.

## Setup

Make the scripts executable once:

```
chmod +x scripts/*.sh
```

## Index

| Script | Purpose |
| --- | --- |
| `lib.sh` | Shared helpers (colored logging). Sourced by the others, not run directly. |
| `init-env.sh` | Copy every `stacks/*/.env.example` to `.env` where missing. |

## Typical order for a fresh clone

1. `./scripts/init-env.sh` then edit every new `.env` with real secrets.
2. Create the external networks (`docker network create core-data` and
   `docker network create monitoring-net`, see `Docs.md`).
3. Start the stacks in Dockge.
