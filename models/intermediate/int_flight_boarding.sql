with flights as (

    select * from {{ ref('stg_flights') }}

),

boarding_passes as (

    select * from {{ ref('stg_boarding_passes') }}

),

flight_boarding_details as (

    select
        f.flight_id,
        f.route_no,
        f.status as flight_status,
        f.scheduled_departure,
        f.scheduled_arrival,
        f.actual_departure,
        f.actual_arrival,
        bp.ticket_no,
        bp.seat_no,
        bp.boarding_no,
        bp.boarding_time,
        {{ generate_flight_type('actual_departure', 'actual_arrival') }} as flight_distance_type
    from flights f
    left join boarding_passes bp on f.flight_id = bp.flight_id

)

select * from flight_boarding_details
