# grafana

Runs as uid/gid `472`, so a one-shot `grafana-init` container
`chown`s `./data` to `472` before the server starts. `provisioning/` holds
the datasource config and is tracked in git, the same pattern as
`glance/provisioning`. Not exposed via NPM; reached only over the Netbird
VPN at `grafana.robotics.lab` (set in `GF_SERVER_ROOT_URL`) - that
hostname needs a Netbird DNS entry pointing at this host. To get the
**Node Exporter Full** dashboard, log in, go to Dashboards -> New ->
Import, enter ID `1860`, and pick the `Prometheus` datasource.
