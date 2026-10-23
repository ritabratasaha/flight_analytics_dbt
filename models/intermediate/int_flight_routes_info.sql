with flights as (

    select * from {{ ref('stg_flights') }}

),

routes as (

    select * from {{ ref('stg_routes') }}

),

flight_routes as (

    select
        f.flight_id,
        f.route_no,
        f.status as flight_status,
        r.departure_airport,
        r.arrival_airport,
        r.airplane_code,
        r.duration
    from flights f
    left join routes r on f.route_no = r.route_no

)

select * from flight_routes
