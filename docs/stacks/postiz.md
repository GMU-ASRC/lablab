# postiz

Social media scheduler. Its own app database and cache point
at the shared `core-postgres` (`postiz` role, `POSTIZ_DB_PASSWORD` must
match `databases/.env`) and `core-valkey`, the same reasoning as kaneo's
Postgres reuse, and the first stack to actually use `core-valkey`. Its
scheduling engine runs on Temporal, which upstream's
`gitroomhq/postiz-docker-compose` bundles as a whole separate cluster
(`temporal`, `temporal-ui`, `temporal-admin-tools`, its own
`temporal-postgresql`, and `temporal-elasticsearch` for visibility
queries); that Postgres stays bundled rather than moving to
`core-postgres` because Temporal's `auto-setup` image needs `CREATEDB`
rights on first boot to provision its own schema, which the roles
`databases/init/01-init-databases.sh` creates deliberately don't have.
`temporal-postgresql`'s data is a bind mount at `./data/temporal-postgres`
(matches the plain-`postgres` bind-mount pattern used elsewhere in this
repo); `postiz-config`, `postiz-uploads`, and `temporal-elasticsearch-data`
stay named Docker volumes instead, since neither image's runtime UID is
documented and getting a bind-mount `chown` wrong would break the
container the same way `grafana`/`prometheus` needed an init container to
avoid. `TEMPORAL_DB_PASSWORD` is local to this stack (not shared with
`databases`) since that Postgres is not `core-postgres`. Elasticsearch may
need `vm.max_map_count >= 262144` set on the host kernel
(`sysctl -w vm.max_map_count=262144`, persist in `/etc/sysctl.d/`) if it
fails to start; upstream's compose file doesn't set this, so check the
container logs on first boot. The Temporal Web UI is remapped to host
port `8088` (upstream default `8080` collides with `glance`), and both it
and Temporal's gRPC port `7233` are bound to `127.0.0.1` only, for
on-host debugging (`temporal` CLI or the web UI over an SSH tunnel), not
meant to be reachable otherwise. Storage for media uploads uses Postiz's
`local` provider (the `postiz-uploads` named volume above) rather than the
RustFS S3 bucket kaneo uses, since Postiz's S3-compatible option is
Cloudflare R2 specifically, not a generic S3 endpoint. Reachable two ways:
directly on host port `4007`, and publicly via the `cloudflared` sidecar
over `core-data` at `postiz:5000`, same pattern as kaneo.
`CLOUDFLARE_TUNNEL_TOKEN` and the tunnel's Public Hostname
(`social.autonomousrobotics.club` pointed at `postiz:5000`) are set up in
Cloudflare Zero Trust, external to this repo, same as kaneo's tunnel.
Authentik SSO is optional and off by default (`POSTIZ_GENERIC_OAUTH`
defaults to `false`); flip it to `true` and set
`POSTIZ_AUTHENTIK_CLIENT_ID`/`POSTIZ_AUTHENTIK_CLIENT_SECRET` once an
OAuth2/OIDC Provider and Application (slug `postiz`) exist in Authentik,
the discovery/auth/token/userinfo URLs assume that slug. This needs its
own Authentik Application, separate from kaneo's. Only three platforms
are wired up in the compose file, matching what the lab actually
posts to: `LINKEDIN_CLIENT_ID`/`LINKEDIN_CLIENT_SECRET` (a LinkedIn
Developer Portal app with the Share on LinkedIn product), `FACEBOOK_APP_ID`/
`FACEBOOK_APP_SECRET` (a Meta for Developers app with the Instagram Graph
API - Postiz's self-hosted Instagram Business connection authenticates
through Facebook Login, there is no separate Instagram app credential),
and `YOUTUBE_CLIENT_ID`/`YOUTUBE_CLIENT_SECRET` (a Google Cloud OAuth
client with the YouTube Data API v3 enabled). All three are optional and
leaving any of them blank just leaves that platform unavailable to
connect in Postiz's UI; more platforms can be added to the compose file
the same way if the lab starts posting elsewhere later. The LinkedIn
channel to connect is the lab's Company Page,
[linkedin.com/company/arcgmu](https://www.linkedin.com/company/arcgmu/) -
connecting it as a Company Page (not a personal profile) is what makes it
show up as `linkedin-page` rather than `linkedin` in the API and enables
LinkedIn analytics.
