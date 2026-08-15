# glance

`provisioning/` holds the actual dashboard config
(`glance.yml`, `pages/`) and is tracked in git, the same way the main
homelab tracks Grafana's `provisioning/` folder. It mounts to `/app/config`
inside the container. Also gets the docker socket (read-only) so the
`docker-containers` widget can show container status, and the host
timezone files so the clock widget matches the host. The bookmarks and
monitor widgets in `pages/dashboard.yml` link to `grafana.robotics.lab`,
`immich.robotics.lab` (immich), and `npm.robotics.lab:81` (NPM's own
admin UI, direct port since NPM can't proxy itself) alongside the
existing `.robotics.lab` entries; all three are naming intent, not yet
backed by an NPM proxy host or Netbird DNS entry, add those before
expecting the links to resolve. `prometheus` is deliberately not linked
from the dashboard; it is still tracked in `pages/system.yml`'s release
widget.
`tasks.autonomousrobotics.club` (kaneo) and `social.autonomousrobotics.club`
(postiz) are the same situation but via Cloudflare Tunnel's Public
Hostname config instead of NPM, see the [kaneo](kaneo.md) and
[postiz](postiz.md) notes. `pages/system.yml`'s release tracker follows
what is actually deployed here, so keep it in sync when adding or
removing a stack.
