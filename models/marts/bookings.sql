with bookings as (

    select * from {{ ref('stg_bookings') }}

),

final as (

    select
        book_ref,
        book_date,
        total_amount,
        date(book_date) as booking_date,
        extract(year from book_date) as booking_year,
        extract(month from book_date) as booking_month,
        _run_id,
        _loaded_at
    from bookings

)

select * from final
