# Networking

## The `core-data` network

`databases` and any stack that uses it need to reach each other by
container name, so they share an external network. Create it once on the
host:

```
docker network create core-data
```

Each consuming stack declares it as external:

```yaml
networks:
  core-data:
    external: true
```

Reach the datastores by container name: `core-postgres` and `core-valkey`.
Start the `databases` stack, and wait until `core-postgres` is healthy,
before starting anything that depends on it. Dockge stacks are independent,
so `depends_on` cannot cross stacks the way `kaneo`'s compose file might
suggest, that ordering has to be done by hand: start `databases` first,
every time.

### If a stack needs a database

`databases/init/01-init-databases.sh` creates a role and database
automatically, but **only on a fresh Postgres data directory**. It already
covers `kaneo` and `postiz`; add a new `create_role_and_db` line there (and the matching
password in `databases/.env`) before that stack's first-ever start. On an
existing data directory the init script does nothing, so a role/database
added later has to be created by hand instead:

```
docker exec -it core-postgres psql -U postgres \
  -c "CREATE ROLE myapp LOGIN PASSWORD 'change_me';" \
  -c "CREATE DATABASE myapp OWNER myapp;"
```

```yaml
services:
  myapp:
    environment:
      - DATABASE_URL=postgresql://myapp:change_me@core-postgres:5432/myapp
    networks:
      - core-data
networks:
  core-data:
    external: true
```

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
