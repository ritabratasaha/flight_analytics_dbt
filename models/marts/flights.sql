with flight_boarding as (

    select * from {{ ref('int_flight_boarding') }}

),

final as (

    select
        flight_id,
        route_no,
        flight_status,
        scheduled_departure,
        scheduled_arrival,
        actual_departure,
        actual_arrival,
        ticket_no,
        seat_no,
        boarding_no,
        boarding_time,
        flight_distance_type
    from flight_boarding

)

select * from final
