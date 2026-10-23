# Flight Analytics

dbt project that transforms Snowflake booking and flight operational data into analytics marts. Incremental models run for a single `processing_date` (boarding date). Airflow can trigger those runs on demand.

Source data lives in Snowflake `FLIGHT_INFORMATION.BOOKINGS`. dbt writes to `FLIGHT_ANALYTICS` in `staging`, `intermediate`, and `marts` schemas.

```text
FLIGHT_INFORMATION.BOOKINGS  →  staging tables  →  intermediate tables  →  marts views
```

## Prerequisites

- Python 3.11+ and [dbt-snowflake](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup) (the Airflow DAG installs `dbt-snowflake==1.7.0`)
- Access to Snowflake databases `FLIGHT_INFORMATION` (read) and `FLIGHT_ANALYTICS` (write)
- Docker and Docker Compose if you want to run Airflow locally

## Setup

Point dbt at the project profile:

```bash
export DBT_PROFILES_DIR="$(pwd)"
```

Edit [profiles.yml](profiles.yml) with your Snowflake account, user, role, warehouse, and database. Use environment variables or a local profile for secrets; do not commit passwords.

## Run dbt locally

```bash
dbt debug
dbt run
dbt test
```

Override the processing date (default in `dbt_project.yml` is `2025-10-02`):

```bash
dbt run --vars '{"processing_date": "2025-10-02"}'
```

Staging models filter boarding activity for that date, then append related flights, tickets, and bookings.

To wipe model tables and start over, run [scripts/truncate_all_tables.sql](scripts/truncate_all_tables.sql) in Snowflake.

## Model layers

| Layer | Schema | Materialization | Models |
| --- | --- | --- | --- |
| Staging | `staging` | Incremental tables (routes/segments as tables) | `stg_bookings`, `stg_tickets`, `stg_flights`, `stg_boarding_passes`, `stg_routes`, `stg_segments` |
| Intermediate | `intermediate` | Tables | `int_bookings_distribution`, `int_flight_routes_info`, `int_flight_boarding`, `int_ticket_snapshot` |
| Marts | `marts` | Views | `bookings`, `flights`, `ticket_snapshot` |

`generate_schema_name` writes models into those schemas as named (no `staging_staging` prefix). `generate_flight_type` labels flights as short, average, or long from actual duration.

## Airflow

From [airflow/](airflow/), start the local stack (UI at http://localhost:8080; default user `admin` / `admin`):

```bash
cd airflow
docker compose up
```

Snowflake credentials are passed through environment variables from `airflow/.env`. The dbt project is mounted at `/opt/airflow/dbt_project`.

| DAG | Purpose |
| --- | --- |
| `dbt_flight_information_daily` | On-demand. Requires param `processing_date` (`YYYY-MM-DD`). Runs `dbt run`, then sets Airflow Variable `dbt_last_processed_date`. |
| `dbt_reset_checkpoint` | Utility. Clears that variable and truncates incremental tables. |

## Repo layout

```text
models/          staging, intermediate, marts, and source.yml
macros/          generate_schema_name, generate_flight_type
airflow/         docker-compose, DAGs
scripts/         truncate_all_tables.sql
profiles.yml     dbt Snowflake connection (local secrets)
dbt_project.yml  project config and default processing_date
```
