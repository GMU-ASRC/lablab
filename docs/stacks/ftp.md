# ftp

Single `stilliard/pure-ftpd` user, TLS enforced (`--tls=2` in
`ADDED_FLAGS`), so this is FTPS only, plaintext FTP connections are
refused. The image generates a self-signed cert on first start if none is
present at `/etc/ssl/private`; `./config/tls` persists it across restarts
so clients don't see a new cert (and a new trust prompt) every time.
`FTP_PUBLIC_HOST` must be the host's real reachable IP or hostname, it is
used both for the passive-mode `PASV` reply and the TLS cert's CN, and
must match on the client side too since passive mode depends on it.
Passive ports `30000-30009` must stay open alongside `2121`. `./data` is
the FTP root, `./config/pureftpd` holds the virtual-user password
database.
