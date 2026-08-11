#!/bin/bash
set -euo pipefail

create_role() {
  local role="$1"
  local password="$2"

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-SQL
    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${role}') THEN
        CREATE ROLE ${role} LOGIN PASSWORD '${password}';
      END IF;
    END
    \$\$;
SQL
}

database_exists() {
  psql -tAc "SELECT 1 FROM pg_database WHERE datname = '$1'" --username "$POSTGRES_USER" | grep -q 1
}

create_role_and_db() {
  local role="$1"
  local password="$2"
  local database="$3"

  create_role "$role" "$password"
  if ! database_exists "$database"; then
    createdb --username "$POSTGRES_USER" --owner "$role" "$database"
  fi
}

create_role_and_db "kaneo" "$KANEO_DB_PASSWORD" "kaneo"
create_role_and_db "coder" "$CODER_DB_PASSWORD" "coder"
