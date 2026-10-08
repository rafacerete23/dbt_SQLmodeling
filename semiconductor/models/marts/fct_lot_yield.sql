-- Yield per lot three ways. The tester's own bin summary counts insertions,
-- which double-counts retested dies.
with insertions as (
    select lot, count(*) as insertions, avg(passed::int) as insertion_yield
    from {{ ref('stg_ate__parts') }}
    group by lot
),
dies as (
    select
        lot,
        count(*) as dies,
        count(*) filter (where insertions > 1) as retested_dies,
        avg(first_pass_passed::int) as first_pass_yield,
        avg(final_passed::int) as final_yield
    from {{ ref('dim_die') }}
    group by lot
)
select
    lot,
    insertions,
    dies,
    retested_dies,
    round(100 * insertion_yield, 2) as insertion_yield_pct,
    round(100 * first_pass_yield, 2) as first_pass_yield_pct,
    round(100 * final_yield, 2) as final_yield_pct
from insertions
join dies using (lot)
