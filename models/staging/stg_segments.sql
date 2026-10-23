{{
    config(
        materialized='table'
    )
}}

with source as (

    select * from {{ source('snowflake', 'segments') }}

),

renamed as (

    select
        ticket_no,
        flight_id,
        fare_conditions,
        price
    from source

)

select * from renamed
