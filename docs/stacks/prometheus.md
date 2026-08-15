# prometheus

Runs as uid/gid `65534` (`nobody`), so a one-shot
`prometheus-init` container `chown`s `./data` to `65534` before the
server starts. Scrapes itself and `node-exporter`
(`stacks/prometheus/prometheus.yml`). `node-exporter` runs with
`network_mode: host` and `pid: host` to read real host metrics, and is
scraped by `prometheus` at `host.docker.internal:9100`
(`extra_hosts: host.docker.internal:host-gateway` resolves the host from
inside the container). Not exposed via NPM; Netbird VPN only, same as
`grafana`.
