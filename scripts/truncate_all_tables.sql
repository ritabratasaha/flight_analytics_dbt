-- Truncate all dbt model tables in FLIGHT_ANALYTICS database

-- Staging tables
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.staging.stg_bookings;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.staging.stg_tickets;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.staging.stg_flights;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.staging.stg_boarding_passes;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.staging.stg_segments;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.staging.stg_routes;

-- Intermediate tables
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.intermediate.int_ticket_snapshot;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.intermediate.int_flight_type;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.intermediate.int_flight_boarding;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.intermediate.int_flight_routes_info;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.intermediate.int_bookings_distribution;
TRUNCATE TABLE IF EXISTS FLIGHT_ANALYTICS.intermediate.int_ticket_information;

-- Marts (views will be recreated by dbt, but drop if they exist as tables)
DROP VIEW IF EXISTS FLIGHT_ANALYTICS.marts.ticket_snapshot;
DROP VIEW IF EXISTS FLIGHT_ANALYTICS.marts.flight_type;
DROP VIEW IF EXISTS FLIGHT_ANALYTICS.marts.bookings;
DROP VIEW IF EXISTS FLIGHT_ANALYTICS.marts.ticket_information;
DROP VIEW IF EXISTS FLIGHT_ANALYTICS.marts.flights;
