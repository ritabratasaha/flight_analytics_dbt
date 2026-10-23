#!/bin/bash
# Wipe FLIGHT_ANALYTICS dbt target tables/views via SnowSQL.
# Usage: ./scripts/truncate_all_tables.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$ROOT/.env"
SQL_FILE="$ROOT/scripts/truncate_all_tables.sql"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: missing env file at $ENV_FILE" >&2
  exit 1
fi

if [[ ! -f "$SQL_FILE" ]]; then
  echo "Error: missing SQL file at $SQL_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

required_vars=(
  SNOWFLAKE_ACCOUNT
  SNOWFLAKE_USER
  SNOWFLAKE_PASSWORD
  SNOWFLAKE_DATABASE
  SNOWFLAKE_WAREHOUSE
  SNOWFLAKE_ROLE
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Error: $var is not set in $ENV_FILE" >&2
    exit 1
  fi
done

export SNOWSQL_PWD="$SNOWFLAKE_PASSWORD"

echo "Truncating Snowflake target tables using conda env dbtenv..."

conda run -n dbtenv --no-capture-output snowsql \
  -a "$SNOWFLAKE_ACCOUNT" \
  -u "$SNOWFLAKE_USER" \
  -d "$SNOWFLAKE_DATABASE" \
  -w "$SNOWFLAKE_WAREHOUSE" \
  -r "$SNOWFLAKE_ROLE" \
  -f "$SQL_FILE" \
  -o friendly=false \
  -o echo=false

echo "Truncate completed."
