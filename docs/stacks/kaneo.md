# kaneo

Task tracker. No bundled Postgres, unlike the upstream Kaneo
compose docs, `DATABASE_URL` points at the shared `core-postgres`
instead (see ["If a stack needs a database"](../networking.md#if-a-stack-needs-a-database));
`KANEO_DB_PASSWORD`
must match `databases/.env`. `AUTH_SECRET` is generated with
`openssl rand -hex 32`, not left as a placeholder. Object storage for
task-description/comment uploads points at the existing RustFS S3
bucket at `bucket.autonomousrobotics.club` (`S3_*` vars) rather than a
new MinIO container; the `kaneo-uploads` bucket and its access key still
need creating on that RustFS instance, that is a manual step on the main
homelab, not something this repo can do. Reachable two ways: directly on
host port `5173`, and publicly via the `cloudflared` sidecar, a
Cloudflare Tunnel client with no inbound port of its own, reaching
`kaneo` over `core-data` at `kaneo:5173`. `CLOUDFLARE_TUNNEL_TOKEN`
comes from Cloudflare Zero Trust -> Networks -> Tunnels -> Create a
tunnel (Docker connector); the tunnel's Public Hostname still needs
pointing at `kaneo:5173` in that same dashboard, and
`tasks.autonomousrobotics.club` needs adding as the public hostname, both
external to this repo. `KANEO_CLIENT_URL` is set to that hostname so the
app generates correct links once the tunnel is live. Login also supports
Authentik: Kaneo has no Authentik-specific integration, but Authentik is
a standard OIDC provider, so it goes through Kaneo's Custom OAuth/OIDC
block (`CUSTOM_OAUTH_*`) via `CUSTOM_OAUTH_DISCOVERY_URL` rather than the
individual authorization/token/userinfo URLs. That needs an OAuth2/OIDC
Provider and an Application created in Authentik first (manual, on the
main homelab's `arcauth` instance), which is where
`AUTHENTIK_CLIENT_ID`/`AUTHENTIK_CLIENT_SECRET` come from; the discovery
URL assumes an application slug of `kaneo`, adjust
`AUTHENTIK_DISCOVERY_URL` if a different slug gets used. Check Kaneo's
own Custom OAuth/OIDC guide for the exact redirect URI to put in
Authentik, that value was not in the docs pulled for this. This adds
Authentik as another login option alongside Kaneo's own email/password
login, it does not replace it: `CUSTOM_OAUTH_AUTO_LOGIN` and
`DISABLE_LOGIN_FORM` are deliberately left unset, Kaneo's own docs warn
that enabling either on an existing installation can lock out local
accounts with unverified email addresses. Repository sync/webhooks are
separate from login: a GitHub App (not the GitHub OAuth App used for
sign-in elsewhere in this repo) provides `GITHUB_APP_ID`,
`GITHUB_WEBHOOK_SECRET`, and a PEM private key. Set the PEM as
`GITHUB_PRIVATE_KEY` with real newlines replaced by literal `\n`
characters (the portable form Kaneo's docs recommend for plain `.env`
files), or base64-encode it into `GITHUB_PRIVATE_KEY_BASE64` instead,
which takes precedence if both are set. `GITHUB_APP_NAME` is optional,
only used for installation links in Kaneo's UI. This whole block is
optional; leaving all five unset just leaves GitHub repo sync/webhooks
off.
