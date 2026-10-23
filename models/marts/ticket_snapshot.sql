with snapshot as (

    select * from {{ ref('int_ticket_snapshot') }}

)

select
    ticket_no,
    book_ref,
    passenger_id,
    passenger_name,
    outbound,
    book_date,
    total_amount,
    is_orphan_booking,
    snapshot_date,
    _run_id,
    _loaded_at
from snapshot
