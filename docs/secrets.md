# Secrets and `.env`

Every stack except `dockge`, `glance`, and `prometheus` needs secrets. Each
has an `.env.example` template; copy it to `.env` and fill in real values
(`API_SECRET_KEY` for worker, `GRAFANA_ADMIN_USER`/`GRAFANA_ADMIN_PASSWORD`
for grafana, `FTP_PUBLIC_HOST`/`FTP_USER_PASS` for ftp, `POSTGRES_PASSWORD`
for databases, `GITEA_RUNNER_TOKEN` for gitea-runner, `DB_PASSWORD` for
immich, `AUTH_SECRET`/`S3_ACCESS_KEY_ID`/`S3_SECRET_ACCESS_KEY`/
`AUTHENTIK_CLIENT_ID`/`AUTHENTIK_CLIENT_SECRET`/`GITHUB_APP_ID`/
`GITHUB_WEBHOOK_SECRET`/`GITHUB_PRIVATE_KEY` for kaneo,
`GITHUB_CLIENT_ID`/`GITHUB_CLIENT_SECRET` for coder, `POSTIZ_DB_PASSWORD`/
`JWT_SECRET`/`TEMPORAL_DB_PASSWORD`/`CLOUDFLARE_TUNNEL_TOKEN` plus optional
`POSTIZ_AUTHENTIK_CLIENT_ID`/`POSTIZ_AUTHENTIK_CLIENT_SECRET` and
`LINKEDIN_CLIENT_ID`/`LINKEDIN_CLIENT_SECRET`/`FACEBOOK_APP_ID`/
`FACEBOOK_APP_SECRET`/`YOUTUBE_CLIENT_ID`/`YOUTUBE_CLIENT_SECRET` for
postiz). `.env` files are gitignored.

`KANEO_DB_PASSWORD`, `CODER_DB_PASSWORD`, and `POSTIZ_DB_PASSWORD` are each
set in two places and must match, same pattern as the main homelab's
shared-database passwords:

| Variable | Set in | Must match |
| --- | --- | --- |
| `KANEO_DB_PASSWORD` | `databases/.env`, `kaneo/.env` | kaneo role |
| `CODER_DB_PASSWORD` | `databases/.env`, `coder/.env` | coder role |
| `POSTIZ_DB_PASSWORD` | `databases/.env`, `postiz/.env` | postiz role |
