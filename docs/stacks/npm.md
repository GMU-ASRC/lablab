# npm

`./data` and `./letsencrypt` hold NPM's own database and
certificates. Both are runtime state, not config-as-code, so they are
gitignored. Admin UI is on port `81`; ports `80`/`443` are the public
reverse proxy.
