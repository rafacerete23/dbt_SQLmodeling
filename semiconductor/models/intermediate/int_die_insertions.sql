-- Numbers each die's test insertions. A die is (lot, x, y): part_id is per
-- insertion, so a retested die has two part_ids.
select
    *,
    row_number() over (partition by lot, x, y order by part_index) as insertion_no,
    count(*) over (partition by lot, x, y) as insertions
from {{ ref('stg_ate__parts') }}
