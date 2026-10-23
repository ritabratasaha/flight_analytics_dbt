{{
    config(
        materialized='incremental',
        unique_key='flight_id',
        incremental_strategy='append'
    )
}}

with boarding_passes as (

    select distinct flight_id 
    from {{ ref('stg_boarding_passes') }}
    where boarding_date = '{{ var("processing_date") }}'::date

),

source as (

    select * from {{ source('snowflake', 'flights') }}
    where flight_id in (select flight_id from boarding_passes)

),

renamed as (

    select
        flight_id,
        route_no,
        status,
        scheduled_departure,
        scheduled_arrival,
        actual_departure,
        actual_arrival,
        '{{ invocation_id }}' as _run_id,
        current_timestamp() as _loaded_at
    from source

)

select * from renamed
