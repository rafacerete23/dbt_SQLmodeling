-- First-pass failing bins per lot with cumulative share, plus how many of
-- those dies passed when retested (high recovery = a test problem, not silicon).
with fails as (
    select lot, first_pass_bin as hard_bin, count(*) as dies,
           count(*) filter (where insertions > 1) as retested,
           count(*) filter (where insertions > 1 and final_passed) as recovered
    from {{ ref('dim_die') }}
    where not first_pass_passed
    group by lot, first_pass_bin
)
select
    lot,
    hard_bin,
    dies,
    round(100 * dies / sum(dies) over (partition by lot), 1) as pct_of_fails,
    round(100 * sum(dies) over (partition by lot order by dies desc, hard_bin
                                rows between unbounded preceding and current row)
              / sum(dies) over (partition by lot), 1) as cum_pct,
    retested,
    recovered,
    round(100 * recovered / nullif(retested, 0), 0) as recovered_pct
from fails
