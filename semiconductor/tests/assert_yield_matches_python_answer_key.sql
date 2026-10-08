-- ate-test-data-pipeline's report.die_yield() is the answer key for lot2:
-- 1,569 insertions, 1,456 dies, 92.24% first pass, 95.40% final.
-- Returns rows (= fails) when the SQL disagrees.
select *
from {{ ref('fct_lot_yield') }}
where lot = 'lot2'
  and not (insertions = 1569 and dies = 1456 and first_pass_yield_pct = 92.24 and final_yield_pct = 95.40)
