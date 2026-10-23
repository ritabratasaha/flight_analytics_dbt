{{
    config(
        materialized='table'
    )
}}

with source as (

    select * from {{ source('snowflake', 'routes') }}

),

renamed as (

    select
        route_no,
        validity,
        departure_airport,
        arrival_airport,
        airplane_code,
        days_of_week,
        scheduled_time,
        duration
    from source

)

select * from renamed
