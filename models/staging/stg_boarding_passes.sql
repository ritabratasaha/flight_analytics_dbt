{{
    config(
        materialized='incremental',
        unique_key=['ticket_no', 'flight_id'],
        incremental_strategy='append'
    )
}}

with source as (

    select * from {{ source('snowflake', 'boarding_passes') }}
    where boarding_time::date = '{{ var("processing_date") }}'

),

renamed as (

    select
        ticket_no,
        flight_id,
        seat_no,
        boarding_no,
        boarding_time,
        boarding_time::date as boarding_date,
        '{{ invocation_id }}' as _run_id,
        current_timestamp() as _loaded_at
    from source

)

select * from renamed
