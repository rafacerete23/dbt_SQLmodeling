-- One row per physical die: first-pass and final result.
select
    lot,
    x,
    y,
    max(insertions) as insertions,
    max(case when insertion_no = 1 then hard_bin end) as first_pass_bin,
    bool_or(case when insertion_no = 1 then passed end) as first_pass_passed,
    max(case when insertion_no = insertions then hard_bin end) as final_bin,
    bool_or(case when insertion_no = insertions then passed end) as final_passed
from {{ ref('int_die_insertions') }}
group by lot, x, y
