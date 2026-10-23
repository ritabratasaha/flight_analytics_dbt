with bookings as (

    select * from {{ ref('stg_bookings') }}

),

bookings_distribution as (

    select
        extract(hour from book_date) as booking_hour,
        count(*) as booking_count,
        sum(total_amount) as total_revenue,
        avg(total_amount) as avg_booking_amount
    from bookings
    group by extract(hour from book_date)
    order by booking_hour

)

select * from bookings_distribution
