{{
    config(
        materialized='incremental',
        unique_key='ticket_no',
        incremental_strategy='append'
    )
}}

with bookings as (

    select distinct book_ref 
    from {{ ref('stg_bookings') }}
    where date(book_date) = '{{ var("processing_date") }}'::date

),

source as (

    select * from {{ source('snowflake', 'tickets') }}
    where book_ref in (select book_ref from bookings)

),

renamed as (

    select
        ticket_no,
        book_ref,
        passenger_id,
        passenger_name,
        outbound,
        '{{ invocation_id }}' as _run_id,
        current_timestamp() as _loaded_at
    from source

)

select * from renamed
