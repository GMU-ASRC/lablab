#!/usr/bin/env bash

c_yellow=$'\033[0;33m'
c_green=$'\033[0;32m'
c_blue=$'\033[0;34m'
c_reset=$'\033[0m'

log() { printf '%s[*]%s %s\n' "$c_blue" "$c_reset" "$*"; }
ok() { printf '%s[+]%s %s\n' "$c_green" "$c_reset" "$*"; }
warn() { printf '%s[!]%s %s\n' "$c_yellow" "$c_reset" "$*" >&2; }
