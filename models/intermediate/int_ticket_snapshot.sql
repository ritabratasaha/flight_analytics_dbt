{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

with tickets as (

    select 
        ticket_no,
        book_ref,
        passenger_id,
        passenger_name,
        outbound 
    from {{ ref('stg_tickets') }}
    where _run_id = (Select Max(_run_id) from {{ ref('stg_tickets') }})

),

bookings as (

    select 
        book_ref,
        book_date,
        total_amount 
    from {{ ref('stg_bookings') }}
    where date(book_date) = '{{ var("processing_date") }}'::date
     and _run_id = (Select Max(_run_id) from {{ ref('stg_bookings') }})

),

snapshot as (

    select
        t.ticket_no,
        b.book_ref,
        t.passenger_id,
        t.passenger_name,
        t.outbound,
        b.book_date,
        b.total_amount,
        case when t.ticket_no is null then true else false end as is_orphan_booking,
        '{{ var("processing_date") }}'::date as snapshot_date,
        '{{ invocation_id }}' as _run_id,
        current_timestamp() as _loaded_at
    from bookings b
    left join tickets t 
        on t.book_ref = b.book_ref

)

select * from snapshot
