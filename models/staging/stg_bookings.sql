{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

with source as (

    select * from {{ source('snowflake', 'bookings') }}
    where date(book_date) = '{{ var("processing_date") }}'

),

renamed as (

    select
        book_ref,
        book_date,
        total_amount,
        '{{ invocation_id }}' as _run_id,
        current_timestamp() as _loaded_at
    from source

)

select * from renamed
