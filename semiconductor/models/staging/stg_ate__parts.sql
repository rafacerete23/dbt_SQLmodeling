-- One row per test insertion. The lot comes from the folder name (…/lot2/parts.parquet).
select
    regexp_extract(filename, '([^/\\]+)[/\\]parts\.parquet$', 1) as lot,
    part_index,
    part_id,
    wafer_id,
    site,
    x,
    y,
    hard_bin,
    soft_bin,
    passed,
    num_tests,
    test_time_ms
from {{ source('ate', 'parts') }}
