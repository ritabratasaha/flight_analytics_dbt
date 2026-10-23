-- RCA: duplicate snapshot_date in marts.ticket_snapshot
SELECT
    snapshot_date,
    _run_id,
    MIN(_loaded_at) AS min_loaded_at,
    MAX(_loaded_at) AS max_loaded_at,
    COUNT(DISTINCT _loaded_at) AS distinct_loaded_at,
    COUNT(*) AS row_cnt
FROM marts.ticket_snapshot
WHERE snapshot_date = '2025-10-02'::date
GROUP BY snapshot_date, _run_id
ORDER BY min_loaded_at;

SELECT
    snapshot_date,
    _run_id,
    _loaded_at,
    COUNT(*) AS row_cnt
FROM marts.ticket_snapshot
WHERE snapshot_date = '2025-10-02'::date
GROUP BY snapshot_date, _run_id, _loaded_at
ORDER BY _loaded_at;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ticket_no) AS distinct_ticket_no,
    COUNT(DISTINCT book_ref) AS distinct_book_ref
FROM marts.ticket_snapshot
WHERE snapshot_date = '2025-10-02'::date;
