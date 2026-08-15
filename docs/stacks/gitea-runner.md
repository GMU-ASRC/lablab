# gitea-runner

`gitea/act_runner`, no local Gitea, just a runner that
registers against the main homelab's Gitea at `git.sirblob.co`
(`GITEA_INSTANCE_URL`). Generate `GITEA_RUNNER_TOKEN` on that instance
(Site Administration -> Actions -> Runners -> Create new runner, or the
repo/org-level equivalent) and copy it into `.env`; a registration token
is single-use, once the runner has registered `./data` holds its
persistent identity, so it does not need to re-register on restart. Gets
the docker socket so Actions jobs can run in containers. No `network_mode:
host` needed here (unlike the main homelab's runner, which reaches its
Gitea over `localhost`); this one only needs outbound HTTPS to
`git.sirblob.co`.
